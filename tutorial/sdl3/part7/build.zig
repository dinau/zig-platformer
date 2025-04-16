const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "platformer_part7",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Load Icon
    exe.addWin32ResourceFile(.{ .file = b.path("src/res/res.rc") });

    // Modules
    const stb_path = "../../libs/stb";
    const sdl_path = "../../libs/sdl/SDL3/x86_64-w64-mingw32";

    const clib_step = b.addTranslateC(.{
        .root_source_file = b.path("../../libs/clib.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const stb_step = b.addTranslateC(.{
        .root_source_file = b.path(b.pathJoin(&.{ stb_path, "stb_image.h" })),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const sdl_step = b.addTranslateC(.{
        .root_source_file = b.path(b.pathJoin(&.{ sdl_path, "include/SDL3/SDL.h" })),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    //---------------
    // Include paths
    //---------------
    exe.addIncludePath(b.path(stb_path));
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
        const sdl_inc_path: std.Build.LazyPath = .{ .cwd_relative = "/usr/include" };
        sdl_step.addIncludePath(sdl_inc_path);
        sdl_step.addIncludePath(b.path("/usr/include/SDL3"));
    }
    // clib module
    exe.root_module.addImport("clib", clib_step.createModule());

    // stb module
    const stb_mod = stb_step.createModule();
    stb_mod.addCSourceFiles(.{
        .files = &.{
            b.pathJoin(&.{ stb_path, "stb_impl.c" }),
        },
    });
    exe.root_module.addImport("stb", stb_mod);

    // sdl module =  sdl3
    const sdl_mod = sdl_step.createModule();
    exe.root_module.addImport("sdl", sdl_mod);

    //------
    // Libs
    //------
    const static_link: bool = false;
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
        if (false) { // Static link on Windows
            exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.a" })));
        } else { // Dynamic link on Windows
            exe.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.dll.a" })));
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
        exe.subsystem = .Windows; // Hide console window
    }

    const TRes = struct { file: []const u8, dir: []const u8 };
    const dir_tutorial = "../../";
    const resBin = [_]TRes{
        TRes{ .file = "bob.png", .dir = dir_tutorial },
        TRes{ .file = "grass.png", .dir = dir_tutorial },
        TRes{ .file = "default.map", .dir = dir_tutorial },
    };

    inline for (resBin) |res| {
        const resource = b.addInstallFile(b.path(res.dir ++ res.file), "bin/" ++ res.file);
        b.getInstallStep().dependOn(&resource.step);
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
