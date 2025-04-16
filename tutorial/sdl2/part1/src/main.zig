const std = @import("std");
const ig = @import("sdl");

const MainWinWidth: i32 = 1280;
const MainWinHeight: i32 = 720;

//--------
// main()
//--------
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

    var count: i16 = 150;

    while (count > 0) : (count -= 1) {
        _ = ig.SDL_RenderClear(renderer);
        ig.SDL_RenderPresent(renderer);
    }

    std.debug.print("{s}", .{"Part1 is OK"});
}
