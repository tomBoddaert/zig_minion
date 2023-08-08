const std = @import("std");

const utils = @import("utils.zig");

const sc = .{
    .empty = @import("empty.zig").run,
    .invalid = @import("invalid.zig").run,
    .help = @import("help.zig").run,
    .assemble = @import("assemble.zig").run,
    .run = @import("run.zig").run,
    .runasm = @import("runasm.zig").run,
    .info = @import("info.zig").run,
};

inline fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub const Subcommand = enum {
    Empty,
    Invalid,
    Help,
    Assemble,
    Run,
    RunAsm,
    Info,

    pub fn parse(str: []const u8) @This() {
        if (eql(str, "")) return .Empty;
        if (eql(str, "help")) return .Help;
        if (eql(str, "assemble")) return .Assemble;
        if (eql(str, "run")) return .Run;
        if (eql(str, "runasm")) return .RunAsm;
        if (eql(str, "info")) return .Info;
        return .Invalid;
    }

    pub inline fn run(self: @This(), comptime Writer: type, app: *utils.App(Writer)) void {
        switch (self) {
            .Empty => sc.empty(Writer, app),
            .Invalid => sc.invalid(Writer, app),
            .Help => sc.help(Writer, app),
            .Assemble => sc.assemble(Writer, app),
            .Run => sc.run(Writer, app),
            .RunAsm => sc.runasm(Writer, app),
            .Info => sc.info(Writer, app),
        }
    }
};
