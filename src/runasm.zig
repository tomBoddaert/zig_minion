const std = @import("std");
const fs = std.fs;

const zm = @import("zig_minion");

const utils = @import("utils.zig");
const runner = @import("runner.zig");

pub fn run(comptime Writer: type, app: *utils.App(Writer)) void {
    const cwd = fs.cwd();

    const in_path = app.arg_iter.next() orelse {
        utils.print(
            Writer,
            &app.stderr,
            "No input file path provided!\n",
            .{},
        );
        return;
    };

    const in_file = cwd.openFile(
        in_path,
        .{},
    ) catch |err| return utils.print(
        Writer,
        &app.stderr,
        "Failed to open input file\n  Error: {}\n",
        .{err},
    );

    const assembly = in_file.readToEndAlloc(app.allocator, 1 << 30) catch
        return utils.print(
        Writer,
        &app.stderr,
        "Input file too large!\n",
        .{},
    );

    const memory = zm.assembler.assemble_str(assembly) catch |err|
        return utils.print(
        Writer,
        &app.stderr,
        "Failed to assemble file!\n  Error: {}\n",
        .{err},
    );

    runner.run(Writer, app, memory);
}
