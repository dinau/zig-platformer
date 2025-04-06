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
    exe.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc") });
    const sdl_base = "../../libs/sdl/SDL3";
    const sdl_path = sdl_base ++ "/" ++ "x86_64-w64-mingw32";
    const stb_base = "../../libs/stb";
    //---------------
    // Include paths
    //---------------
    exe.addIncludePath(b.path(stb_base));
    //
    if (builtin.target.os.tag == .windows) {
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include" })));
    } else if (builtin.target.os.tag == .macos) {
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
    } else if (builtin.target.os.tag == .linux) {
        const sdl_inc_path: std.Build.LazyPath = .{ .cwd_relative = "/usr/include/SDL3" };
        exe.addIncludePath(sdl_inc_path);
    }
    //---------------
    // Sources C/C++
    //---------------
    exe.addCSourceFiles(.{
        .files = &.{
            b.pathJoin(&.{stb_base,"stb_impl.c"}),
        },
        .flags = &.{
            "-O2",
        },
    });

    //------
    // Libs
    //------
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
        if (false){ // Static link on Windows
        exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.a" })));
        }else{     // Dynamic link on Windows
          exe.addObjectFile(b.path(b.pathJoin(&.{sdl_path, "lib","libSDL3.dll.a"})));
        }
    } else if (builtin.target.os.tag == .macos) {
        exe.linkSystemLibrary("sdl");
    } else if (builtin.target.os.tag == .linux) {
        exe.linkSystemLibrary("glfw3");
        exe.linkSystemLibrary("GL");
        exe.linkSystemLibrary("sdl");
    }

    b.installArtifact(exe);
    exe.linkLibC();
    if (builtin.target.os.tag == .windows) {
        exe.subsystem = .Windows;  // Hide console window
    }

    const TRes= struct {file:[]const u8, dir:[]const u8};
    const dir_tutorial = "../../";
    const resBin = [_]TRes{
        TRes{.file = "mushroom.png", .dir = dir_tutorial},
        TRes{.file = "grass.png",    .dir = dir_tutorial},
        TRes{.file = "default.map",  .dir = dir_tutorial},
    };

    inline for (resBin) |res| {
        const resource = b.addInstallFile(b.path(res.dir ++ res.file), "bin/" ++ res.file);
        b.getInstallStep().dependOn(&resource.step);
    }

    if (builtin.target.os.tag == .windows) {
      const sdl3_dll = "SDL3.dll";
      const resource = b.addInstallFile(b.path(sdl_path ++ "/bin/" ++ sdl3_dll), "bin/" ++  sdl3_dll);
      b.getInstallStep().dependOn(&resource.step);
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
