const std = @import("std");
const ig = @import("sdl3");

const RendererPtr = *ig.SDL_Renderer;

const Input = enum { none, left, right, jump, restart, quit };
const Game = struct {
    renderer: RendererPtr,
    inputs: [6]bool,
};

const MainWinWidth: i32 = 1280;
const MainWinHeight: i32 = 720;

//---------
//-- write
//---------
fn write(str: []const u8) void { // for print
    std.debug.print("{s}", .{str});
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

//------------
//--- newGame   -- Game type
//------------
fn newGame(renderer: RendererPtr) Game {
    return Game{
        .renderer = renderer,
        .inputs = [6]bool{ false, false, false, false, false, false },
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
    _ = ig.SDL_RenderPresent(self.renderer);
}

//--------
// main()
//--------
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

    var game = newGame(renderer);

    //-----------
    // Main loop     Game loop, draws each frame
    //-----------
    while (!game.inputs[@as(usize, @intFromEnum(Input.quit))]) {
        handleInput(&game);
        render(&game);
    }
}
