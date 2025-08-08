const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get executable name from current directory name
    const allocator = b.allocator;
    const abs_path = b.build_root.handle.realpathAlloc(allocator, ".") catch unreachable;
    defer allocator.free(abs_path);
    const exe_name = std.fs.path.basename(abs_path);

    const exe = b.addExecutable(.{
        .name = exe_name,
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Load Icon
    exe.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc") });

    // Modules
    const sdl_base = "../../libs/sdl/SDL3";
    const sdl_path = sdl_base ++ "/" ++ "x86_64-w64-mingw32";
    const sdl_step = b.addTranslateC(.{
        .root_source_file = b.path(b.pathJoin(&.{ sdl_path, "include/SDL3/SDL.h" })),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    //---------------
    // Include paths
    //---------------
    //
    if (builtin.target.os.tag == .windows) {
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include" }));
        sdl_step.addIncludePath(sdl_inc_path);
        sdl_step.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include" })));
    } else if (builtin.target.os.tag == .macos) { // ? TODO
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include" }));
        sdl_step.addIncludePath(sdl_inc_path);
        sdl_step.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
    } else if (builtin.target.os.tag == .linux) { // ? TODO
        sdl_step.addIncludePath(.{ .cwd_relative = "/usr/local/include" });
        sdl_step.addIncludePath(.{ .cwd_relative = "/usr/local/include/SDL3"});
    }
    b.installArtifact(exe);

    // sdl module =  sdl3
    const sdl_mod = sdl_step.createModule();
    exe.root_module.addImport("sdl", sdl_mod);

    //------
    // Libs
    //------
    const static_link: bool = false;
    if (builtin.target.os.tag == .windows) {
        const libs = [_][]const u8{ "gdi32", "imm32", "advapi32", "comdlg32", "dinput8", "dxerr8", "dxguid", "gdi32", "hid", "kernel32", "ole32", "oleaut32", "setupapi", "shell32", "user32", "uuid", "version", "winmm", "winspool", "ws2_32", "opengl32", "shell32", "user32" };
        for (libs) |lib| {
            exe.root_module.linkSystemLibrary(lib, .{});
        }
        if (false) { // Static link on Windows
            exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.a" })));
        } else { // Dynamic link on Windows
            exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.dll.a" })));
        }
    } else if (builtin.target.os.tag == .macos) {
        exe.root_module.linkSystemLibrary("sdl3", .{});
    } else if (builtin.target.os.tag == .linux) {
        exe.root_module.linkSystemLibrary("GL", .{});
        exe.root_module.linkSystemLibrary("SDL3",  .{});
    }

    b.installArtifact(exe);
    exe.linkLibC();
    if (builtin.target.os.tag == .windows) {
        //exe.subsystem = .Windows; // Hide console window
    }

    // Copy *.dll to bin folder
    if (!static_link) {
        if (builtin.target.os.tag == .windows) {
            const sdl3_dll = "SDL3.dll";
            const resource = b.addInstallFile(b.path(sdl_path ++ "/bin/" ++ sdl3_dll), "bin/" ++ sdl3_dll);
            b.getInstallStep().dependOn(&resource.step);
        }
    }

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
