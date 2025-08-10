const std = @import("std");
const builtin = @import("builtin");

pub fn copyAssets(b: *std.Build, assets: [][]const u8) void {
    for (assets) |asset| {
        const dir_assets = "../../";
        const resource = b.addInstallFile(b.path(b.pathJoin(&.{dir_assets, asset})), b.pathJoin(&.{"bin/" , asset}));
        b.getInstallStep().dependOn(&resource.step);
    }
}

pub fn copydll_sdl2(b: *std.Build) void {
    // Copy *.dll to bin folder
    const sdl_base = "../../libs/sdl/SDL2";
    const sdl_path = sdl_base ++ "/" ++ "x86_64-w64-mingw32";
    const static_link: bool = false;
    if (!static_link) {
        if (builtin.target.os.tag == .windows) {
            const sdl2_dll = "SDL2.dll";
            const resource = b.addInstallFile(b.path(sdl_path ++ "/bin/" ++ sdl2_dll), "bin/" ++ sdl2_dll);
            b.getInstallStep().dependOn(&resource.step);
        }
    }
}

pub fn copydll_sdl2_ttf(b: *std.Build) void {
    const sdl_ttf_path = "../../libs/sdl/SDL2_ttf";
    if (builtin.target.os.tag == .windows) {
        const sdl2_ttf_dll = "SDL2_ttf.dll";
        const resource = b.addInstallFile(b.path(sdl_ttf_path ++ "/lib/x64/" ++ sdl2_ttf_dll), "bin/" ++ sdl2_ttf_dll);
        b.getInstallStep().dependOn(&resource.step);
    }
}

pub fn runCmd(b: *std.Build,  exe: *std.Build.Step.Compile ) void {
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
