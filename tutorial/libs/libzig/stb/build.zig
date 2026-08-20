const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod_name = "stb";

    // Modules
    const stb_path = "../../stb";

    const step = b.addTranslateC(.{
        .root_source_file = b.path(b.pathJoin(&.{ stb_path, "stb_image.h" })),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // stb module
    const mod = step.addModule(mod_name);
    mod.addCSourceFiles(.{
        .files = &.{
            b.pathJoin(&.{ stb_path, "stb_impl.c" }),
        },
    });
    mod.addImport(mod_name, mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = mod_name,
        .root_module = mod,
    });

    // Libs
    b.installArtifact(lib);
}
