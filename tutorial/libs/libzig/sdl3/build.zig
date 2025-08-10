const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get executable name from current directory name
    const allocator = b.allocator;
    const abs_path = b.build_root.handle.realpathAlloc(allocator, ".") catch unreachable;
    defer allocator.free(abs_path);
    const mod_name = std.fs.path.basename(abs_path);

    // SDL3
    const sdl_base = "../../sdl";
    const sdl_path     = sdl_base ++ "/SDL3/x86_64-w64-mingw32";
    const sdl_ttf_path = sdl_base ++ "/SDL3_ttf/x86_64-w64-mingw32";
    const step = b.addTranslateC(.{
        .root_source_file = b.path("src/impl_sdl.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    step.defineCMacro("SDL_ENABLE_OLD_NAMES", "");
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);

    //---------------
    // Include paths
    //---------------
    //
    if (builtin.target.os.tag == .windows) {
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include" }));
        step.addIncludePath(sdl_inc_path);
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
        //mod.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include/SDL3_ttf" })));
    } else if (builtin.target.os.tag == .macos) { // ? TODO
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include" }));
        step.addIncludePath(sdl_inc_path);
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include/SDL3_ttf" })));
    } else if (builtin.target.os.tag == .linux) { // ? TODO
        step.addIncludePath(.{ .cwd_relative = "/usr/local/include" });
        step.addIncludePath(.{ .cwd_relative = "/usr/local/include/SDL3"});
        step.addIncludePath(.{.cwd_relative = "/usr/local/include/SDL3_ttf"});
    }

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });

    // Libs
    if (builtin.target.os.tag == .windows) {
        const libs = [_][]const u8{ "gdi32", "imm32", "advapi32", "comdlg32", "dinput8", "dxerr8", "dxguid", "gdi32", "hid", "kernel32", "ole32", "oleaut32", "setupapi", "shell32", "user32", "uuid", "version", "winmm", "winspool", "ws2_32", "opengl32", "shell32", "user32" };
        for (libs) |dlllib| {
            lib.root_module.linkSystemLibrary(dlllib, .{});
        }
        if (false) { // Static link on Windows
            lib.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.a" })));
        } else { // Dynamic link on Windows
            lib.addObjectFile(b.path(b.pathJoin(&.{ sdl_path, "lib", "libSDL3.dll.a" })));
            lib.addObjectFile(b.path(b.pathJoin(&.{ sdl_ttf_path, "lib", "libSDL3_ttf.dll.a" })));
        }
    } else if (builtin.target.os.tag == .macos) {
        lib.root_module.linkSystemLibrary("sdl3", .{});
    } else if (builtin.target.os.tag == .linux) {
        lib.root_module.linkSystemLibrary("GL", .{});
        lib.root_module.linkSystemLibrary("SDL3",  .{});
        lib.root_module.linkSystemLibrary("SDL3_ttf",  .{});
    }

    b.installArtifact(lib);
}
