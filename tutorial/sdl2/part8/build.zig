const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addStaticLibrary(.{
        .name = "part8",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);
    const exe = b.addExecutable(.{
        .name = "platformer_part8",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Load Icon
    exe.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc") });
    const sdl2_base =     "../../libs/sdl/SDL2";
    const sdl2_ttf_base = "../../libs/sdl/SDL2_ttf";
    const sdl2_path     = sdl2_base ++ "/" ++ "x86_64-w64-mingw32";
    const sdl2_ttf_path = sdl2_ttf_base;
    const stb_base = "../../libs/stb";
    //---------------
    // Include paths
    //---------------
    exe.addIncludePath(b.path("../../libs/stb"));
    //
    if (builtin.target.os.tag == .windows) {
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl2_path,     "include/SDL2" })));
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl2_ttf_path, "include" })));
    } else if (builtin.target.os.tag == .macos) {
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl2_path,     "include/SDL2" })));
        exe.addIncludePath(b.path(b.pathJoin(&.{ sdl2_ttf_path, "include" })));
    } else if (builtin.target.os.tag == .linux) {
        const sdl2_inc_path: std.Build.LazyPath =     .{ .cwd_relative = "/usr/include/SDL2" };
        exe.addIncludePath(sdl2_inc_path);
        const sdl2_ttf_inc_path: std.Build.LazyPath = .{ .cwd_relative = "/usr/include/SDL2_ttf" };
        exe.addIncludePath(sdl2_ttf_inc_path);
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
          exe.addObjectFile(b.path(b.pathJoin(&.{ sdl2_path,     "lib", "libSDL2.a" })));
          exe.addObjectFile(b.path(b.pathJoin(&.{ sdl2_ttf_path, "lib", "x64", "SDL2_ttf.lib" })));
        }else{     // Dynamic link on Windows
          exe.addObjectFile(b.path(b.pathJoin(&.{sdl2_path,     "lib","libSDL2.dll.a"})));
          exe.addObjectFile(b.path(b.pathJoin(&.{sdl2_ttf_path, "lib", "x64", "SDL2_ttf.lib"})));
        }
    } else if (builtin.target.os.tag == .macos) {
        exe.linkSystemLibrary("sdl2");
        exe.linkSystemLibrary("sdl2_ttf"); // TODO ?
    } else if (builtin.target.os.tag == .linux) {
        exe.linkSystemLibrary("glfw3");
        exe.linkSystemLibrary("GL");
        exe.linkSystemLibrary("sdl2");
        exe.linkSystemLibrary("sdl2_ttf"); // TODO ?
    }

    b.installArtifact(exe);
    exe.linkLibC();
    if (builtin.target.os.tag == .windows) {
        exe.subsystem = .Windows; // Hide console window
    }

    const resBin = [_][]const u8{
        "mushroom.png",
        "grass.png",
        "default.map",
        "DejaVuSans.ttf",
    };
    inline for (resBin) |file| {
        const res = b.addInstallFile(b.path("../../" ++ file), "bin/" ++ file);
        b.getInstallStep().dependOn(&res.step);
    }

    if (builtin.target.os.tag == .windows) {
        const sdl_dll = "SDL2.dll";
        var res = b.addInstallFile(b.path(sdl2_path ++ "/bin/"  ++ sdl_dll), "bin/" ++ sdl_dll);
        b.getInstallStep().dependOn(&res.step);
        const ttf_dll = "SDL2_ttf.dll";
        res = b.addInstallFile(b.path(sdl2_ttf_path ++ "/lib/x64/"  ++ ttf_dll), "bin/" ++ ttf_dll);
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
