const std = @import("std");
const builtin = @import("builtin");
const Build = std.Build;

const emccOutputDir = "zig-out" ++ std.fs.path.sep_str ++ "htmlout" ++ std.fs.path.sep_str;
const emccOutputFile = "index.html";

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addStaticLibrary(.{
        .name = "lib",
        .root_source_file = .{ .path = "main.zig" },
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .cpu_model = .{ .explicit = &std.Target.wasm.cpu.mvp },
            .cpu_features_add = std.Target.wasm.featureSet(&.{
                .atomics,
                .bulk_memory,
            }),
            .os_tag = .emscripten,
        }),
        .optimize = optimize,
        .link_libc = true,
    });
    lib.shared_memory = true;
    lib.root_module.single_threaded = false;
    b.installArtifact(lib);

    if (b.sysroot == null) {
        @panic("pass '--sysroot \"[path to emsdk]/upstream/emscripten\"'");
    }

    const emccExe = switch (builtin.os.tag) {
        .windows => "emcc.bat",
        else => "emcc",
    };
    var emcc_run_arg = try b.allocator.alloc(
        u8,
        b.sysroot.?.len + emccExe.len + 1,
    );
    defer b.allocator.free(emcc_run_arg);

    emcc_run_arg = try std.fmt.bufPrint(
        emcc_run_arg,
        "{s}" ++ std.fs.path.sep_str ++ "{s}",
        .{ b.sysroot.?, emccExe },
    );

    const mkdir_command = b.addSystemCommand(&[_][]const u8{
        "mkdir",
        "-p",
        emccOutputDir,
    });
    const emcc_command = b.addSystemCommand(&[_][]const u8{emcc_run_arg});
    emcc_command.addFileArg(lib.getEmittedBin());
    emcc_command.step.dependOn(&lib.step);
    emcc_command.step.dependOn(&mkdir_command.step);
    emcc_command.addArgs(&[_][]const u8{
        "-o",
        emccOutputDir ++ emccOutputFile,
        "-pthread",
        "-sASYNCIFY",
        "-sPTHREAD_POOL_SIZE=4",
        "-sINITIAL_MEMORY=167772160",
        //"-sEXPORTED_FUNCTIONS=_main,__builtin_return_address",
    });
    // USE_OFFSET_CONVERTER required for @returnAddress used in
    // std.mem.Allocator interface
    emcc_command.addArgs(&[_][]const u8{
        "-sUSE_OFFSET_CONVERTER",
    });
    b.getInstallStep().dependOn(&emcc_command.step);
}
