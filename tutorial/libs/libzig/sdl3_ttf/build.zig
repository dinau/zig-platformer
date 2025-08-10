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

    const sdl_ttf_path = "../../sdl/SDL3_ttf/x86_64-w64-mingw32";
    const sdl_path     = "../../sdl/SDL3/x86_64-w64-mingw32";

    // SDL_ttf
    const step = b.addTranslateC(.{
        .root_source_file = b.path(b.pathJoin(&.{ sdl_ttf_path, "include/SDL3_ttf/SDL_ttf.h" })),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    if (builtin.target.os.tag == .windows) {
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include" }));
        step.addIncludePath(sdl_inc_path);
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include/SDL3_ttf" })));
    } else if (builtin.target.os.tag == .macos) { // ? TODO
        const sdl_inc_path = b.path(b.pathJoin(&.{ sdl_path, "include" }));
        step.addIncludePath(sdl_inc_path);
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_path, "include/SDL3" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include" })));
        step.addIncludePath(b.path(b.pathJoin(&.{ sdl_ttf_path, "include/SDL3_ttf" })));
    } else if (builtin.target.os.tag == .linux) { // ? TODO
        step.addIncludePath(.{.cwd_relative = "/usr/local/include"});
        step.addIncludePath(.{.cwd_relative = "/usr/local/include/SDL3"});
        step.addIncludePath(.{.cwd_relative = "/usr/local/include/SDL3_ttf"});
    }

    // Module
    const mod = step.addModule(mod_name);
    mod.addImport(mod_name, mod);

    //------
    // Libs
    //------

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });

    if (builtin.target.os.tag == .windows) {
            lib.addObjectFile(b.path(b.pathJoin(&.{ sdl_ttf_path, "lib", "libSDL3_ttf.dll.a" })));
    } else if (builtin.target.os.tag == .macos) {
    } else if (builtin.target.os.tag == .linux) {
        lib.root_module.linkSystemLibrary("SDL3_ttf",  .{});
    }
    // Libs
    b.installArtifact(lib);
}
