const std = @import("std");

pub fn App(comptime Writer: type) type {
    return struct {
        stdout: Writer,
        stderr: Writer,
        allocator: std.mem.Allocator,
        command: []const u8,
        arg_iter: std.process.ArgIterator,
    };
}

pub fn app(stdout: anytype, stderr: @TypeOf(stdout), allocator: std.mem.Allocator, command: []const u8, arg_iter: std.process.ArgIterator) App(@TypeOf(stdout)) {
    return .{
        .stdout = stdout,
        .stderr = stderr,
        .allocator = allocator,
        .command = command,
        .arg_iter = arg_iter,
    };
}

pub fn print(comptime Writer: type, writer: *Writer, comptime format: []const u8, args: anytype) void {
    writer.writer().print(format, args) catch @panic("Failed to write to stdout!");
    writer.flush() catch @panic("Failed to write to stdout!");
}
