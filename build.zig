const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const static = b.addExecutable(.{
        .name = "dev",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    static.defineCMacro("WEBVIEW_STATIC", null);
    static.linkLibC();
    static.linkLibCpp();

    static.subsystem = .Windows;

    switch (target.result.os.tag) {
        .windows => {
            static.addCSourceFile(.{ .file = .{ .cwd_relative = "ext/webview/webview.cc" }, .flags = &.{"-std=c++14"} });
            static.addIncludePath(.{ .cwd_relative = "ext/windows/webview2/include/" });
            static.addIncludePath(.{ .cwd_relative = "ext/windows/sdk/10.0.22621.2428/" });

            // system libs
            static.linkSystemLibrary("ole32");
            static.linkSystemLibrary("shlwapi");
            static.linkSystemLibrary("version");
            static.linkSystemLibrary("advapi32");
            static.linkSystemLibrary("shell32");
            static.linkSystemLibrary("user32");
        }, 
        else => {}
    }

    b.installArtifact(static);

    const run_cmd = b.addRunArtifact(static);

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
