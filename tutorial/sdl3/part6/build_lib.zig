const std = @import("std");
const builtin = @import("builtin");

pub fn copyAssets(b: *std.Build, assets: [][]const u8) void {
    for (assets) |asset| {
        const dir_assets = "../../";
        const resource = b.addInstallFile(b.path(b.pathJoin(&.{dir_assets, asset})), b.pathJoin(&.{"bin/" , asset}));
        b.getInstallStep().dependOn(&resource.step);
    }
}

pub fn copydll_sdl3(b: *std.Build) void {
    // Copy *.dll to bin folder
    const sdl_base = "../../libs/sdl/SDL3";
    const sdl_path = sdl_base ++ "/" ++ "x86_64-w64-mingw32";
    const static_link: bool = false;
    if (!static_link) {
        if (builtin.target.os.tag == .windows) {
            const sdl3_dll = "SDL3.dll";
            const resource = b.addInstallFile(b.path(sdl_path ++ "/bin/" ++ sdl3_dll), "bin/" ++ sdl3_dll);
            b.getInstallStep().dependOn(&resource.step);
        }
    }
}

pub fn copydll_sdl3_ttf(b: *std.Build) void {
    const sdl_ttf_path = "../../libs/sdl/SDL3_ttf/x86_64-w64-mingw32";
    if (builtin.target.os.tag == .windows) {
        const sdl3_ttf_dll = "SDL3_ttf.dll";
        const resource = b.addInstallFile(b.path(sdl_ttf_path ++ "/bin/" ++ sdl3_ttf_dll), "bin/" ++ sdl3_ttf_dll);
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
