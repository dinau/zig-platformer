const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "platformer_part2",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Load Icon
    exe.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc") });

    // Modules
    const sdl_path = "../../libs/sdl/SDL2/x86_64-w64-mingw32";
    const sdl_step = b.addTranslateC(.{
        .root_source_file = b.path(b.pathJoin(&.{ sdl_path, "include/SDL2/SDL.h" })),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    //---------------
    // Include paths
    //---------------
    if (builtin.target.os.tag == .windows) {
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include/SDL2" }));
        sdl_step.addIncludePath(sdl_inc_path);
    } else if (builtin.target.os.tag == .macos) {
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include/SDL2" }));
        sdl_step.addIncludePath(sdl_inc_path);
    } else if (builtin.target.os.tag == .linux) {
        const sdl_inc_path: std.Build.LazyPath = .{ .cwd_relative = "/usr/include/SDL2" };
        sdl_step.addIncludePath(sdl_inc_path);
    }

    // sdl module
    const sdl_mod = sdl_step.createModule();
    exe.root_module.addImport("sdl", sdl_mod);

    //------
    // Libs
    //------
    const static_link: bool = true;
    if (builtin.target.os.tag == .windows) {
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("imm32");
        exe.linkSystemLibrary("advapi32");
        exe.linkSystemLibrary("comdlg32");
        exe.linkSystemLibrary("dinput8");
        exe.linkSystemLibrary("dxerr8");
        exe.linkSystemLibrary("dxguid");
        exe.linkSystemLibrary("gdi32");
        exe.linkSystemLibrary("hid");
        exe.linkSystemLibrary("kernel32");
        exe.linkSystemLibrary("ole32");
        exe.linkSystemLibrary("oleaut32");
        exe.linkSystemLibrary("setupapi");
        exe.linkSystemLibrary("shell32");
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("uuid");
        exe.linkSystemLibrary("version");
        exe.linkSystemLibrary("winmm");
        exe.linkSystemLibrary("winspool");
        exe.linkSystemLibrary("ws2_32");
        exe.linkSystemLibrary("opengl32");
        exe.linkSystemLibrary("shell32");
        exe.linkSystemLibrary("user32");
        if (static_link) { // Static link on Windows
            exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL2.a" })));
        } else { // Dynamic link on Windows
            exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL2.dll.a" })));
        }
    } else if (builtin.target.os.tag == .macos) {
        exe.linkSystemLibrary("sdl2");
    } else if (builtin.target.os.tag == .linux) {
        exe.linkSystemLibrary("glfw3");
        exe.linkSystemLibrary("GL");
        exe.linkSystemLibrary("SDL2");
    }

    b.installArtifact(exe);
    exe.linkLibC();
    if (builtin.target.os.tag == .windows) {
        //exe.subsystem = .Windows;  // Hide console window
    }
    // Copy *.dll to bin folder
    if (!static_link) {
        if (builtin.target.os.tag == .windows) {
            const sdl_dll = "SDL2.dll";
            var res = b.addInstallFile(b.path(sdl_path ++ "/bin/" ++ sdl_dll), "bin/" ++ sdl_dll);
            b.getInstallStep().dependOn(&res.step);
        }
    }

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
