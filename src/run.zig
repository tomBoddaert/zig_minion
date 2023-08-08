const std = @import("std");
const fs = std.fs;

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

    if ((in_file.metadata() catch @panic("Failed to get file metadata!")).size() != 200)
        return utils.print(
            Writer,
            &app.stderr,
            "Input file is not the correct size!",
            .{},
        );

    var memory_buf: [200]u8 = undefined;
    _ = in_file.readAll(&memory_buf) catch return utils.print(
        Writer,
        &app.stderr,
        "Input file too large!\n",
        .{},
    );

    const memory = std.mem.bytesAsValue([100]u10, &memory_buf);
    runner.run(Writer, app, memory.*);
}
