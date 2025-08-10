const std = @import("std");
const ig = @import("sdl3");

const MainWinWidth: i32 = 1280;
const MainWinHeight: i32 = 720;

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

    var count: i16 = 150;

    while (count > 0) : (count -= 1) {
        _ = ig.SDL_RenderClear(renderer);
        _ = ig.SDL_RenderPresent(renderer);
    }

    std.debug.print("\n{s}", .{"Part1 is OK"});
}
