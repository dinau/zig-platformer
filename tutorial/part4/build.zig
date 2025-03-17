const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addStaticLibrary(.{
        .name = "part4",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);
    const exe = b.addExecutable(.{
        .name = "platformer_part4",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Load Icon
    exe.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc")});
    const sdl2_Base = "../libs/sdl/SDL2-2.30.9";
    const sdl2_path = b.fmt("{s}/x86_64-w64-mingw32", .{sdl2_Base});
    //---------------
    // Include paths
    //---------------
    exe.addIncludePath(b.path("../libs/stb"));
    //
    if (builtin.target.os.tag == .windows){
      exe.addIncludePath(b.path(b.pathJoin(&.{sdl2_path, "include/SDL2"})));
    } else if (builtin.target.os.tag == .linux){
      const sdl2_inc_path: std.Build.LazyPath = .{ .cwd_relative = "/usr/include/SDL2" };
      exe.addIncludePath(sdl2_inc_path);
    }
    //---------------
    // Sources C/C++
    //---------------
    exe.addCSourceFiles(.{
      .files = &.{
        "../libs/stb/stb_impl.c",
      },
      .flags = &.{
        "-O2",
      },
    });

    //------
    // Libs
    //------
    if (builtin.target.os.tag == .windows){
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
      // Static link
      exe.addObjectFile(b.path(b.pathJoin(&.{sdl2_path, "lib","libSDL2.a"})));
    }else if (builtin.target.os.tag == .linux){
      exe.linkSystemLibrary("glfw3");
      exe.linkSystemLibrary("GL");
      exe.linkSystemLibrary("sdl2");
    }

    b.installArtifact(exe);
    // sdl2
    //exe.addLibraryPath(b.path(b.pathJoin(&.{sdl2_path, "lib-mingw-64"})));
    //exe.linkSystemLibrary("SDL2");      // For static link
    // Dynamic link
    //exe.addObjectFile(b.path(b.pathJoin(&.{sdl2_path, "lib","libSDL2dll.a"})));
    //exe.linkSystemLibrary("SDL2dll"); // For dynamic link
    exe.linkLibC();
    //exe.subsystem = .Windows;  // Hide console window

    const resBin =   [_][]const u8{ "mushroom.png", "grass.png", "default.map", };
    inline for(resBin)|file|{
      const res = b.addInstallFile(b.path("../" ++ file),"bin/" ++ file);
      b.getInstallStep().dependOn(&res.step);
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
