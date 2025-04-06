const std = @import("std");
const ig = @cImport({
    @cDefine("SDL_ENABLE_OLD_NAMES","");
    @cInclude("SDL.h");
    @cInclude("stb_image.h");
    @cInclude("time.h");
});

const TexturePtr  = *ig.SDL_Texture;
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
const Collision = enum { x, y, corner };
const Player = struct { texture: TexturePtr, pos: Vec2f, vel: Vec2f };
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
const PlayerSize = vec2f(64, 64);

const MainWinWidth: i32 = 1024;
const MainWinHeight: i32 = 800;

const air = 0;
const start = 78;
const finish = 110;

//--- Camera moving attribute
const FluidCamera = true;
const InnerCamera = false;

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
const TBodyParts = struct { src: ig.SDL_FRect, dest: ig.SDL_FRect, flip: u32 };
inline fn newBodyParts(src: ig.SDL_FRect, dest: ig.SDL_FRect, flip: u32) TBodyParts {
 return TBodyParts{.src = src, .dest = dest, .flip = flip};
}

//--------------
//--- renderTee
//--------------
fn renderTee(renderer: RendererPtr, texture: TexturePtr, pos: Vec2f) void {
    const x = pos.x;
    const y = pos.y;
    const bodyParts = [8]TBodyParts{
        newBodyParts(newFRect(192, 64, 64, 32), newFRect(x - 60, y,      96, 48), ig.SDL_FLIP_NONE),       //-- back feet shadow
        newBodyParts(newFRect(96,   0, 96, 96), newFRect(x - 48, y - 48, 96, 96), ig.SDL_FLIP_NONE),       //-- body shadow
        newBodyParts(newFRect(192, 64, 64, 32), newFRect(x - 36, y,      96, 48), ig.SDL_FLIP_NONE),       //-- front feet shadow
        newBodyParts(newFRect(192, 32, 64, 32), newFRect(x - 60, y,      96, 48), ig.SDL_FLIP_NONE),       //-- back feet
        newBodyParts(newFRect(0,    0, 96, 96), newFRect(x - 48, y - 48, 96, 96), ig.SDL_FLIP_NONE),       //-- body
        newBodyParts(newFRect(192, 32, 64, 32), newFRect(x - 36, y,      96, 48), ig.SDL_FLIP_NONE),       //-- front feet
        newBodyParts(newFRect(64,  96, 32, 32), newFRect(x - 18, y - 21, 36, 36), ig.SDL_FLIP_NONE),       //-- left eye
        newBodyParts(newFRect(64,  96, 32, 32), newFRect(x - 6,  y - 21, 36, 36), ig.SDL_FLIP_HORIZONTAL), //-- right eye
    };
    for (bodyParts) |v| {
        _ = ig.SDL_RenderTextureRotated(renderer, texture, &v.src, &v.dest, 0.0, null, v.flip);
    }
}

//--------------
//--- renderMap
//--------------
fn renderMap(renderer: RendererPtr, map: Map, camera: ig.SDL_FPoint) void {
    var clip = ig.SDL_FRect{ .x = 0, .y = 0, .w = TileSize.x, .h = TileSize.y };
    var dest = ig.SDL_FRect{ .x = 0, .y = 0, .w = TileSize.x, .h = TileSize.y };
    for (map.tiles.items, 0..) |tileNr, i| {
        if (tileNr != 0) {
            clip.x = @floatFromInt((tileNr % TilesPerRow) * TileSize.x);
            clip.y = @floatFromInt((tileNr / TilesPerRow) * TileSize.y);
            const n = @as(c_int, @intCast(i));
            dest.x = @floatFromInt(@mod(n, map.width) * TileSize.x - @as(c_int, @intFromFloat(camera.x)));
            dest.y = @floatFromInt(@divFloor(n, map.width) * TileSize.y - @as(c_int, @intFromFloat(camera.y)));
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

const DebugPrint = false;
fn write(str: []const u8) void { // for print
    if (DebugPrint) {
        std.debug.print("{s}", .{str});
    }
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
fn newMap(alloc: std.mem.Allocator, texture: TexturePtr, mapfile: []const u8) !Map {
    var map = Map{ .width = 0, .height = 0, .texture = texture, .tiles = std.ArrayList(u8).init(alloc) };
    var fp = try std.fs.cwd().openFile(mapfile, .{});
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
            std.debug.print("Incompatible line length in map:  {s} ", .{mapfile});
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
    while (ig.SDL_PollEvent(&event)) {
        const kind = event.type;
        if (kind == ig.SDL_QUIT) {
            self.inputs[@intFromEnum(Input.quit)] = true;
        } else if (kind == ig.SDL_KEYDOWN) {
            write("\n[KeyDown]");
            self.inputs[toInput(event.key.scancode)] = true;
        } else if (kind == ig.SDL_KEYUP) {
            write("\n[KeyUp]");
            self.inputs[toInput(event.key.scancode)] = false;
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
    _ = ig.SDL_RenderPresent(self.renderer);
}

//------------
//--- getTile
//------------
fn getTile(map: Map, x: f32, y: f32) u8 {
    const nx = std.math.clamp(std.math.floor(x / TileSize.x), 0, @as(f32, @floatFromInt(map.width - 1)));
    const ny = std.math.clamp(std.math.floor(y / TileSize.y), 0, @as(f32, @floatFromInt(map.height - 1)));
    const pos = std.math.ceil(ny * @as(f32, @floatFromInt(map.width)) + nx);
    return map.tiles.items[@as(usize, @intFromFloat(pos))];
}
//-------------
//--- isSolid
//-------------
fn isSolid(map: Map, pos: Vec2f) bool {
    const val = getTile(map, std.math.ceil(pos.x), std.math.ceil(pos.y));
    return (val != air) and (val != start) and (val != finish);
}

//-------------
//--- onGround
//-------------
fn onGround(map: Map, pos: Vec2f, size: Vec2f) bool {
    const sz  = vec2f(size.x * 0.5, size.y * 0.5);
    const pt1 = vec2f(pos.x - sz.x, pos.y + sz.y + 1);
    const pt2 = vec2f(pos.x + sz.x, pos.y + sz.y + 1);
    return isSolid(map, pt1) or isSolid(map, pt2);
}

//------------
//--- testBox
//------------
fn testBox(map: Map, pos: Vec2f, size: Vec2f) bool {
    const sz = vec2f(size.x * 0.5, size.y * 0.5);
    return isSolid(map, vec2f(pos.x - sz.x, pos.y - sz.y)) or
        isSolid(map,    vec2f(pos.x + sz.x, pos.y - sz.y)) or
        isSolid(map,    vec2f(pos.x - sz.x, pos.y + sz.y)) or
        isSolid(map,    vec2f(pos.x + sz.x, pos.y + sz.y));
}

//----------------
//--- vector2dLen
//----------------
fn vector2dLen(vec: Vec2f) f32 {
    return std.math.sqrt((vec.x * vec.x) + (vec.y * vec.y));
}

//------------
//--- moveBox
//------------
fn moveBox(self: *Game, size: Vec2f) void { // vector(Collision)
    const distance = vector2dLen(self.player.vel);
    const maximum = std.math.floor(distance);
    if (distance < 0) {
        return;
    }

    const fraction = 1.0 / (maximum + 1);
    //local result: vector(Collision)
    var i: i32 = 0;
    while (i < @as(i32, @intFromFloat(maximum))) {
        var newPos = vec2f(0.0, 0.0);
        newPos.x = self.player.pos.x + (self.player.vel.x * fraction);
        newPos.y = self.player.pos.y + (self.player.vel.y * fraction);

        if (testBox(self.map, newPos, size)) {
            var hit = false;
            var pt = vec2f(self.player.pos.x, newPos.y);
            if (testBox(self.map, pt, size)) {
                //result:push(Collision.y)
                newPos.y = self.player.pos.y;
                self.player.vel.y = 0;
                hit = true;
            }

            pt = vec2f(newPos.x, self.player.pos.y);
            if (testBox(self.map, pt, size)) {
                //result:push(Collision.x)
                newPos.x = self.player.pos.x;
                self.player.vel.x = 0;
                hit = true;
            }

            if (!hit) {
                //result:push(Collision.corner)
                //-- newPos = self.player.pos
                self.player.pos = newPos;
                self.player.vel = vec2f(0.0, 0.0);
            }
        }
        self.player.pos = newPos;
        i += 1;
    } //-- while end
}

fn boolToInt(b: bool) i32 {
    if (b) {
        return 1;
    } else {
        return 0;
    }
}

//------------
//--- physics
//------------
fn physics(self: *Game) void {
    if (self.inputs[@intFromEnum(Input.restart)]) {
        restartPlayer(&self.player);
    }

    const ground = onGround(self.map, self.player.pos, PlayerSize);

    if (self.inputs[@intFromEnum(Input.jump)]) {
        if (ground) {
            self.player.vel.y = -21;
        }
    }
    const direction = boolToInt(self.inputs[@intFromEnum(Input.right)]) -
        boolToInt(self.inputs[@intFromEnum(Input.left)]); //-- direction is [0 or 1 or -1]

    self.player.vel.y = self.player.vel.y + 0.75;
    if (ground) {
        self.player.vel.x = 0.5 * self.player.vel.x + 4.0 * @as(f32, @floatFromInt(direction));
    } else {
        self.player.vel.x = 0.95 * self.player.vel.x + 2.0 * @as(f32, @floatFromInt(direction));
    }
    self.player.vel.x = std.math.clamp(self.player.vel.x, -8, 8);

    moveBox(self, PlayerSize);
}

//---------------
//--- moveCamera
//---------------
fn moveCamera(self: *Game) void{
  const halfWin = MainWinWidth / 2;
  if (FluidCamera) {
    const dist = self.camera.x - self.player.pos.x + halfWin;
    self.camera.x = self.camera.x - 0.05 * dist;
    //std.debug.print(dist,self.camera.x);
  } else if(InnerCamera){
    const leftArea  = self.player.pos.x - halfWin - 100;
    const rightArea = self.player.pos.x - halfWin + 100;
    self.camera.x = std.math.clamp(self.camera.x, leftArea, rightArea);
  } else{
    self.camera.x = self.player.pos.x - halfWin;
  }
}

//----------------------
// SDL_CreateRGBSurface      # For Compatibility with SDL2
//----------------------
inline fn SDL_CreateRGBSurfaceFrom(pixels: [*c]u8, width:c_int, height:c_int, depth:c_int, pitch:c_int , Rmask: c_uint, Gmask:c_uint, Bmask:c_uint, Amask:c_uint) *ig.SDL_Surface {
  return ig.SDL_CreateSurfaceFrom(width, height,
                               ig.SDL_GetPixelFormatForMasks(depth, Rmask, Gmask, Bmask, Amask),
                              pixels, pitch);
}

//------------------------
//--- loadTextureFromFile
//------------------------
fn loadTextureFromFile(filename: [*c]const u8, renderer: RendererPtr, outWidth: *c_int, outHeight: *c_int) ?TexturePtr {
    var channels: c_int = 4;
    const image_data = ig.stbi_load(filename, outWidth, outHeight, &channels, 4);
    defer ig.stbi_image_free(image_data);
    const surface = SDL_CreateRGBSurfaceFrom(image_data, outWidth.*, outHeight.*, channels * 8, channels * outWidth.*, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
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
    if (!ig.SDL_Init(ig.SDL_INIT_VIDEO | ig.SDL_INIT_GAMEPAD)) {
        std.debug.print("Error: {s}\n", .{ig.SDL_GetError()});
        return error.SDL_init;
    }
    defer ig.SDL_Quit();
    //-----------------------------
    //--- Setting OpenGL3 backend
    //-----------------------------
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_FLAGS, 0);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_PROFILE_MASK, ig.SDL_GL_CONTEXT_PROFILE_CORE);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    _ = ig.SDL_GL_SetAttribute(ig.SDL_GL_CONTEXT_MINOR_VERSION, 3);

    const window = ig.SDL_CreateWindow("Our own 2D platformer written in Zig", MainWinWidth, MainWinHeight, ig.SDL_WINDOW_OPENGL | ig.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        std.debug.print("Error: SDL_CreateWindow(): {s}\n", .{ig.SDL_GetError()});
        return error.SDL_CreatWindow;
    }
    defer ig.SDL_DestroyWindow(window);
    std.debug.print("\nSDL3 version : {d}", .{ig.SDL_GetVersion()});
    std.debug.print("\nSDL3 revision : {s}", .{ig.SDL_GetRevision()});

    const renderer = ig.SDL_CreateRenderer(window, null).?;
    defer ig.SDL_DestroyRenderer(renderer);

    _ = ig.SDL_SetRenderVSync(renderer, 1);

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
    //
    const fname2: [*c]const u8 = "grass.png";
    const texture_grass = loadTextureFromFile(fname2, renderer, &w, &h).?;
    defer ig.SDL_DestroyTexture(texture_grass);

    // NewGame
    var game = try newGame(alloc, renderer, texture_player, texture_grass);

    const startTime:c_long = ig.clock();
    var lastTick:c_long = 0;

    //-----------
    // Main loop     Game loop, draws each frame
    //-----------
    while (!game.inputs[@as(usize, @intFromEnum(Input.quit))]) {
        handleInput(&game);
        const newTick = @divFloor(((ig.clock() - startTime) * 50), 1000);
        var n = newTick - (lastTick + 1);
        while (n >= 0) : (n -= 1) {
            physics(&game);
            moveCamera(&game);
        }
        lastTick = newTick;
        render(&game);
    }

    _ = ig.SDL_GL_SwapWindow(window);
    _ = ig.SDL_ShowWindow(window);
}
