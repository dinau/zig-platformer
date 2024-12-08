const std = @import("std");
const ig = @cImport({
    @cInclude("SDL.h");
});

const Input = enum { none, left, right, jump, restart, quit };
const Game = struct {
    renderer: *ig.SDL_Renderer,
    inputs: [6]bool,
};

const MainWinWidth: i32 = 1024;
const MainWinHeight: i32 = 800;

//---------
//-- write
//---------
fn write(str: []const u8) !void { // for print
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("{s}", .{str});
    try bw.flush();
}

//-----------
//-- toInput
//-----------
fn toInput(key: u32) !usize {
    var res = Input.none;
    try write("\n");
    if (key == ig.SDL_SCANCODE_A or key == ig.SDL_SCANCODE_H or key == ig.SDL_SCANCODE_LEFT) {
        try write("LEFT: ");
        res = Input.left;
    } else if (key == ig.SDL_SCANCODE_D or key == ig.SDL_SCANCODE_L or key == ig.SDL_SCANCODE_RIGHT) {
        try write("RIGHT: ");
        res = Input.right;
    } else if (key == ig.SDL_SCANCODE_UP or key == ig.SDL_SCANCODE_SPACE or key == ig.SDL_SCANCODE_J or key == ig.SDL_SCANCODE_K) {
        try write("JUMP: ");
        res = Input.jump;
    } else if (key == ig.SDL_SCANCODE_R) {
        try write("Rstart: ");
        res = Input.restart;
    } else if (key == ig.SDL_SCANCODE_Q or key == ig.SDL_SCANCODE_ESCAPE) {
        try write("Quit: ");
        res = Input.quit;
    } else {
        try write("None: ");
        res = Input.none;
    }
    return @as(usize, @intFromEnum(res));
}

//------------
//--- newGame   -- Game type
//------------
fn newGame(renderer: *ig.SDL_Renderer) Game {
    return Game{
        .renderer = renderer,
        .inputs = [6]bool{ false, false, false, false, false, false },
    };
}

//--------------------
//-- Game:handleInput
//--------------------
fn handleInput(self: *Game) !void {
    var event: ig.SDL_Event = undefined;
    while (ig.SDL_PollEvent(&event) != 0) {
        const kind = event.type;
        if (kind == ig.SDL_QUIT) {
            self.inputs[@intFromEnum(Input.quit)] = true;
        } else if (kind == ig.SDL_KEYDOWN) {
            try write("\n[KeyDown]");
            self.inputs[try toInput(event.key.keysym.scancode)] = true;
        } else if (kind == ig.SDL_KEYUP) {
            try write("\n[KeyUp]");
            self.inputs[try toInput(event.key.keysym.scancode)] = false;
        }
    }
}

//-----------
//--- render
//-----------
fn render(self: *Game) void {
    _ = ig.SDL_RenderClear(self.renderer);
    ig.SDL_RenderPresent(self.renderer);
}

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
    try bw.flush();

    const renderer = ig.SDL_CreateRenderer(window, -1, ig.SDL_RENDERER_ACCELERATED | ig.SDL_RENDERER_PRESENTVSYNC);
    defer ig.SDL_DestroyRenderer(renderer);

    _ = ig.SDL_SetRenderDrawColor(renderer, 110, 132, 174, 255);

    var game = newGame(renderer.?);

    //--------------
    //--- Main loop
    //--------------
    //-- Game loop, draws each frame
    while (!game.inputs[@as(usize, @intFromEnum(Input.quit))]) {
        try handleInput(&game);
        render(&game);
    }

    ig.SDL_GL_SwapWindow(window);
    ig.SDL_ShowWindow(window);
} // main end
