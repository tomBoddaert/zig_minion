const std = @import("std");

const utils = @import("utils.zig");
const Subcommand = @import("subcommand.zig").Subcommand;

pub fn main() void {
    const stdout_file = std.io.getStdOut().writer();
    var stdout = std.io.bufferedWriter(stdout_file);

    const stderr_file = std.io.getStdErr().writer();
    var stderr = std.io.bufferedWriter(stderr_file);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.argsWithAllocator(allocator) catch @panic("Failed to allocate space for comand line arguments!");

    const command = args.next() orelse @panic("Failed to get command line arguments!");

    const subcommand = if (args.next()) |sc| Subcommand.parse(sc) else .Empty;
    var app = utils.app(stdout, stderr, allocator, command, args);

    const Writer = @TypeOf(stdout);
    subcommand.run(Writer, &app);
}
