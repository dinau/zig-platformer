const std = @import("std");
const ig = @cImport({
    @cInclude("SDL.h");
});

const MainWinWidth: i32 = 1024;
const MainWinHeight: i32 = 800;

//--------
// main()
//--------
pub fn main() !void {
    //-------------
    // For print()
    //-------------
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    //----------------
    // Initialize SDL
    //----------------
    if (ig.SDL_Init(ig.SDL_INIT_VIDEO | ig.SDL_INIT_TIMER | ig.SDL_INIT_EVENTS) != 0) {
        try stdout.print("Error: {s}\n", .{ig.SDL_GetError()});
        return error.SDL_init;
    }
    defer ig.SDL_Quit();

    const window = ig.SDL_CreateWindow("Our own 2D platformer written in Zig", ig.SDL_WINDOWPOS_CENTERED, ig.SDL_WINDOWPOS_CENTERED, MainWinWidth, MainWinHeight, ig.SDL_WINDOW_SHOWN);
    if (window == null) {
        try stdout.print("Error: SDL_CreateWindow(): {s}\n", .{ig.SDL_GetError()});
        return error.SDL_CreatWindow;
    }
    defer ig.SDL_DestroyWindow(window);

    const renderer = ig.SDL_CreateRenderer(window, -1, ig.SDL_RENDERER_ACCELERATED | ig.SDL_RENDERER_PRESENTVSYNC);
    defer ig.SDL_DestroyRenderer(renderer);

    _ = ig.SDL_SetRenderDrawColor(renderer, 110, 132, 174, 255);

    var count: i16 = 150;

    while (count > 0) : (count -= 1) {
        _ = ig.SDL_RenderClear(renderer);
        ig.SDL_RenderPresent(renderer);
    }

    try stdout.print("{s}", .{"Part1 is OK"});
    try bw.flush();

    ig.SDL_GL_SwapWindow(window);
    ig.SDL_ShowWindow(window);
} // main end
