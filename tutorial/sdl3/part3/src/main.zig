const std = @import("std");
const ig = @import("sdl");
const stb = @import("stb");

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
const Player = struct {
    texture: TexturePtr,
    pos: Vec2f,
    vel: Vec2f,
};
const Game = struct {
    renderer: RendererPtr,
    inputs: [6]bool,
    player: Player,
    camera: ig.SDL_FPoint,
};

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
inline fn vec2f(x: f32, y: f32) Vec2f {
    return Vec2f{ .x = x, .y = y };
}

//-----------
//-- vec2i
//-----------
inline fn vec2i(x: i32, y: i32) Vec2i {
    return Vec2i{ .x = x, .y = y };
}

//-----------
//-- newRect
//-----------
inline fn newRect(x: i32, y: i32, w: i32, h: i32) ig.SDL_Rect {
    return ig.SDL_Rect{ .x = x, .y = y, .w = w, .h = h };
}

//-----------
//-- newFRect
//-----------
inline fn newFRect(x: f32, y: f32, w: f32, h: f32) ig.SDL_FRect {
    return ig.SDL_FRect{ .x = x, .y = y, .w = w, .h = h };
}

//----------------
//-- newBodyParts
//----------------
const TBodyParts = struct { src: ig.SDL_FRect, dest: ig.SDL_FRect, flip: u32 };
inline fn newBodyParts(src: ig.SDL_FRect, dest: ig.SDL_FRect, flip: u32) TBodyParts {
    return TBodyParts{ .src = src, .dest = dest, .flip = flip };
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

//-----------
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

//------------
//--- newGame   -- Game type
//------------
fn newGame(renderer: RendererPtr, texture: TexturePtr) Game {
    return Game{
        .renderer = renderer,
        .inputs = [6]bool{ false, false, false, false, false, false },
        .player = newPlayer(texture),
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
        if (kind == ig.SDL_EVENT_QUIT) {
            self.inputs[@intFromEnum(Input.quit)] = true;
        } else if (kind == ig.SDL_EVENT_KEY_DOWN) {
            write("\n[KeyDown]");
            self.inputs[toInput(event.key.scancode)] = true;
        } else if (kind == ig.SDL_EVENT_KEY_UP) {
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
    _ = ig.SDL_RenderPresent(self.renderer);
}

//----------------------
// SDL_CreateRGBSurface      # For Compatibility with SDL2
//----------------------
inline fn SDL_CreateRGBSurfaceFrom(pixels: [*c]u8, width: c_int, height: c_int, depth: c_int, pitch: c_int, Rmask: c_uint, Gmask: c_uint, Bmask: c_uint, Amask: c_uint) *ig.SDL_Surface {
    return ig.SDL_CreateSurfaceFrom(width, height, ig.SDL_GetPixelFormatForMasks(depth, Rmask, Gmask, Bmask, Amask), pixels, pitch);
}

//------------------------
//--- loadTextureFromFile
//------------------------
fn loadTextureFromFile(filename: [*c]const u8, renderer: RendererPtr, outWidth: *c_int, outHeight: *c_int) ?TexturePtr {
    var channels: c_int = 4;
    const image_data = stb.stbi_load(filename, outWidth, outHeight, &channels, 4);
    defer stb.stbi_image_free(image_data);
    const surface = SDL_CreateRGBSurfaceFrom(image_data, outWidth.*, outHeight.*, channels * 8, channels * outWidth.*, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
    const outTexture = ig.SDL_CreateTextureFromSurface(renderer, surface);
    defer ig.SDL_DestroySurface(surface);
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

    var w: c_int = undefined;
    var h: c_int = undefined;
    const fname: [*c]const u8 = "bob.png";
    const texture = loadTextureFromFile(fname, renderer, &w, &h).?;
    defer ig.SDL_DestroyTexture(texture);
    var game = newGame(renderer, texture);

    //-----------
    // Main loop     Game loop, draws each frame
    //-----------
    while (!game.inputs[@as(usize, @intFromEnum(Input.quit))]) {
        handleInput(&game);
        render(&game);
    }
}
