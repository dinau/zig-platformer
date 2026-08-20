const std = @import("std");
const builtin = @import("builtin");
const blib = @import("build_lib.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_name = "part4";

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    const lib_names = [_][]const u8{ "sdl3", "stb" };
    for (lib_names) |lib_name| {
        main_mod.addImport(lib_name, b.lazyDependency(lib_name, .{}).?.module(lib_name));
    }

    const exe = b.addExecutable(.{
        .name = exe_name,
        .root_module = main_mod,
    });

    if (builtin.target.os.tag == .windows) {
        // Hide console window for Windows OS
        //exe.subsystem = if (builtin.zig_version.minor >= 17) .windows else .windows;
        // Load Icon
        exe.root_module.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc") });
    }

    b.installArtifact(exe);

    // Copy assets to bin folder
    var assets = [_][]const u8{ "Bob.png", "default.map", "grass.png" };
    blib.copyAssets(b, assets[0..]);

    // Copy SDL3 dlls to bin folder
    blib.copydll_sdl3(b);

    // Install run command
    blib.runCmd(b, exe);
}
