const std = @import("std");
const ig = @import("sdl");
const stb = @import("stb");

const TexturePtr = *ig.SDL_Texture;
const RendererPtr = *ig.SDL_Renderer;

const Vec2f = struct {
    x: f32,
    y: f32,
};

const Vec2i = struct {
    x: c_int,
    y: c_int,
};

const Input = enum { none, left, right, jump, restart, quit };

const Player = struct {
  texture: TexturePtr,
  pos: Vec2f,
  vel: Vec2f
};

const Map = struct {
    texture: TexturePtr,
    width: c_int,
    height: c_int,
    tiles: std.ArrayList(u8),
};

const Game = struct {
    renderer: RendererPtr,
    inputs: [6]bool,
    player: Player,
    map: Map,
    camera: ig.SDL_FPoint,
};

const TilesPerRow = 16;
const TileSize   = vec2i(64, 64);

const MainWinWidth: i32 = 1280;
const MainWinHeight: i32 = 720;

//---------
//-- write
//---------
fn write(str: []const u8) void { // for print
    std.debug.print("{s}", .{str});
}

//-----------
//-- vec2f
//-----------
inline fn vec2f(x:f32, y:f32) Vec2f {
  return Vec2f{ .x = x, .y = y};
}

//-----------
//-- vec2i
//-----------
inline fn vec2i(x:i32, y:i32) Vec2i {
  return Vec2i{ .x = x, .y = y};
}

//-----------
//-- newRect
//-----------
inline fn newRect(x:i32, y:i32, w:i32, h:i32) ig.SDL_Rect {
  return ig.SDL_Rect{ .x = x, .y = y, .w = w, .h = h};
}

//-----------
//-- newFRect
//-----------
inline fn newFRect(x:f32, y:f32, w:f32, h:f32) ig.SDL_FRect {
  return ig.SDL_FRect{.x = x, .y = y, .w = w, .h = h};
}

//----------------
//-- newBodyParts
//----------------
const TBodyParts = struct { rect: ig.SDL_Rect, frect: ig.SDL_FRect, flip: u32 };
inline fn newBodyParts(rect: ig.SDL_Rect, frect: ig.SDL_FRect, flip: u32) TBodyParts {
 return TBodyParts{.rect = rect, .frect = frect, .flip = flip};
}

//--------------
//--- renderTee
//--------------
fn renderTee(renderer: RendererPtr, texture: TexturePtr, pos: Vec2f) void {
    const x = pos.x;
    const y = pos.y;
    const bodyParts = [8]TBodyParts{
        newBodyParts(newRect(192, 64, 64, 32), newFRect(x - 60, y,      96, 48), ig.SDL_FLIP_NONE),       //-- back feet shadow
        newBodyParts(newRect(96,   0, 96, 96), newFRect(x - 48, y - 48, 96, 96), ig.SDL_FLIP_NONE),       //-- body shadow
        newBodyParts(newRect(192, 64, 64, 32), newFRect(x - 36, y,      96, 48), ig.SDL_FLIP_NONE),       //-- front feet shadow
        newBodyParts(newRect(192, 32, 64, 32), newFRect(x - 60, y,      96, 48), ig.SDL_FLIP_NONE),       //-- back feet
        newBodyParts(newRect(0,    0, 96, 96), newFRect(x - 48, y - 48, 96, 96), ig.SDL_FLIP_NONE),       //-- body
        newBodyParts(newRect(192, 32, 64, 32), newFRect(x - 36, y,      96, 48), ig.SDL_FLIP_NONE),       //-- front feet
        newBodyParts(newRect(64,  96, 32, 32), newFRect(x - 18, y - 21, 36, 36), ig.SDL_FLIP_NONE),       //-- left eye
        newBodyParts(newRect(64,  96, 32, 32), newFRect(x - 6,  y - 21, 36, 36), ig.SDL_FLIP_HORIZONTAL), //-- right eye
    };
    for (bodyParts) |v| {
        _ = ig.SDL_RenderCopyExF(renderer, texture, &v.rect, &v.frect, 0.0, null, v.flip);
    }
}

//--------------
//--- renderMap
//--------------
fn renderMap(renderer: RendererPtr, map: Map, camera: ig.SDL_FPoint) void {
    var clip = ig.SDL_Rect{ .x = 0, .y = 0, .w = TileSize.x, .h = TileSize.y };
    var dest = ig.SDL_Rect{ .x = 0, .y = 0, .w = TileSize.x, .h = TileSize.y };
    for (map.tiles.items, 0..) |tileNr, i| {
        if (tileNr != 0) {
            clip.x = (tileNr % TilesPerRow) * TileSize.x;
            clip.y = (tileNr / TilesPerRow) * TileSize.y;
            const n = @as(c_int, @intCast(i));
            dest.x = @mod(n, map.width) * TileSize.x - @as(c_int, @intFromFloat(camera.x));
            dest.y = @divFloor(n, map.width) * TileSize.y - @as(c_int, @intFromFloat(camera.y));
            _ = ig.SDL_RenderCopy(renderer, map.texture, &clip, &dest);
        }
    }
}

//------------
//--- toInput
//------------
fn toInput(key: u32) usize {
    var res = Input.none;
    write("\n");
    if (key == ig.SDL_SCANCODE_A or key == ig.SDL_SCANCODE_H or key == ig.SDL_SCANCODE_LEFT) {
        write("LEFT: ");
        res = Input.left;
    } else if (key == ig.SDL_SCANCODE_D or key == ig.SDL_SCANCODE_L or key == ig.SDL_SCANCODE_RIGHT) {
        write("RIGHT: ");
        res = Input.right;
    } else if (key == ig.SDL_SCANCODE_UP or key == ig.SDL_SCANCODE_SPACE or key == ig.SDL_SCANCODE_J or key == ig.SDL_SCANCODE_K) {
        write("JUMP: ");
        res = Input.jump;
    } else if (key == ig.SDL_SCANCODE_R) {
        write("Rstart: ");
        res = Input.restart;
    } else if (key == ig.SDL_SCANCODE_Q or key == ig.SDL_SCANCODE_ESCAPE) {
        write("Quit: ");
        res = Input.quit;
    } else {
        write("None: ");
        res = Input.none;
    }
    return @as(usize, @intFromEnum(res));
}

//------------------
//--- restartPlayer
//------------------
const restartPos = vec2f(170, 500); // -- Initial pos
const restartVel = vec2f(0.0, 0.0); // -- Initial vel

fn restartPlayer(self: *Player) void {
    self.pos = restartPos;
    self.vel = restartVel;
}

//--------------
//--- newPlayer   -- Player type
//--------------
fn newPlayer(texture: TexturePtr) Player {
    return Player{
        .texture = texture,
        .pos = restartPos,
        .vel = restartVel,
    };
}

//-----------
//--- newMap     -- : Map type
//-----------
fn newMap(alloc: std.mem.Allocator, texture: TexturePtr, file: []const u8) !Map {
    var map = Map{ .width = 0, .height = 0, .texture = texture, .tiles = std.ArrayList(u8).init(alloc) };
    var fp = try std.fs.cwd().openFile(file, .{});
    defer fp.close();
    var buf_reader = std.io.bufferedReader(fp.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var width: c_int = 0;
        var it = std.mem.tokenizeAny(u8, line, " ");
        while (it.next()) |word| {
            const n = try std.fmt.parseInt(u8, word, 10);
            try map.tiles.append(n);
            width += 1;
        }
        if ((map.width > 0) and (map.width != width)) {
            std.debug.print("Incompatible line length in map:  {s} ", .{file});
        }
        map.width = width;
        map.height += 1;
    }
    return map;
}

//------------
//--- newGame   -- Game type
//------------
fn newGame(alloc: std.mem.Allocator, renderer: RendererPtr, texture_player: TexturePtr, texture_grass: TexturePtr) !Game {
    return Game{
        .renderer = renderer,
        .inputs = [6]bool{ false, false, false, false, false, false },
        .player = newPlayer(texture_player),
        .map = try newMap(alloc, texture_grass, "default.map"),
        .camera = ig.SDL_FPoint{ .x = 0, .y = 0 },
    };
}

//----------------
//--- handleInput
//----------------
fn handleInput(self: *Game) void {
    var event: ig.SDL_Event = undefined;
    while (ig.SDL_PollEvent(&event) != 0) {
        const kind = event.type;
        if (kind == ig.SDL_QUIT) {
            self.inputs[@intFromEnum(Input.quit)] = true;
        } else if (kind == ig.SDL_KEYDOWN) {
            write("\n[KeyDown]");
            self.inputs[toInput(event.key.keysym.scancode)] = true;
        } else if (kind == ig.SDL_KEYUP) {
            write("\n[KeyUp]");
            self.inputs[toInput(event.key.keysym.scancode)] = false;
        }
    }
}

//-----------
//--- render
//-----------
fn render(self: *Game) void {
    _ = ig.SDL_RenderClear(self.renderer);
    const p = vec2f(self.player.pos.x - self.camera.x, self.player.pos.y - self.camera.y);
    renderTee(self.renderer, self.player.texture, p);
    renderMap(self.renderer, self.map, self.camera);
    ig.SDL_RenderPresent(self.renderer);
}

//------------------------
//--- loadTextureFromFile
//------------------------
fn loadTextureFromFile(filename: [*c]const u8, renderer: *ig.SDL_Renderer, outWidth: *c_int, outHeight: *c_int) ?*ig.SDL_Texture {
    var channels: c_int = 4;
    const image_data = stb.stbi_load(filename, outWidth, outHeight, &channels, 4);
    defer stb.stbi_image_free(image_data);
    const surface = ig.SDL_CreateRGBSurfaceFrom(image_data, outWidth.*, outHeight.*, channels * 8, channels * outWidth.*, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
    const outTexture = ig.SDL_CreateTextureFromSurface(renderer, surface);
    defer ig.SDL_FreeSurface(surface);
    return outTexture;
}

//---------
//--- main
//---------
pub fn main() !void {
    //----------------
    // Initialize SDL
    //----------------
    if (ig.SDL_Init(ig.SDL_INIT_VIDEO | ig.SDL_INIT_TIMER | ig.SDL_INIT_EVENTS) != 0) {
        std.debug.print("Error: {s}\n", .{ig.SDL_GetError()});
        return error.SDL_init;
    }
    defer ig.SDL_Quit();

    const window = ig.SDL_CreateWindow("Our own 2D platformer written in Zig", ig.SDL_WINDOWPOS_CENTERED, ig.SDL_WINDOWPOS_CENTERED, MainWinWidth, MainWinHeight, ig.SDL_WINDOW_SHOWN);
    if (window == null) {
        std.debug.print("Error: SDL_CreateWindow(): {s}\n", .{ig.SDL_GetError()});
        return error.SDL_CreatWindow;
    }
    defer ig.SDL_DestroyWindow(window);

    const renderer = ig.SDL_CreateRenderer(window, -1, ig.SDL_RENDERER_ACCELERATED | ig.SDL_RENDERER_PRESENTVSYNC).?;
    defer ig.SDL_DestroyRenderer(renderer);

    _ = ig.SDL_SetRenderDrawColor(renderer, 110, 132, 174, 255);

    // Alloator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var w: c_int = undefined;
    var h: c_int = undefined;
    const fname: [*c]const u8 = "mushroom.png";
    const texture_player = loadTextureFromFile(fname, renderer, &w, &h).?;
    defer ig.SDL_DestroyTexture(texture_player);
    const fname2: [*c]const u8 = "grass.png";
    const texture_grass = loadTextureFromFile(fname2, renderer, &w, &h).?;
    defer ig.SDL_DestroyTexture(texture_grass);

    // NewGame
    var game = try newGame(alloc, renderer, texture_player, texture_grass);

    //-----------
    // Main loop     Game loop, draws each frame
    //-----------
    while (!game.inputs[@as(usize, @intFromEnum(Input.quit))]) {
        handleInput(&game);
        render(&game);
    }
}
