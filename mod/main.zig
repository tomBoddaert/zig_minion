const std = @import("std");
const testing = std.testing;

pub const parser = @import("parser/main.zig");
pub const assembler = @import("assembler.zig");
pub const computer = @import("computer.zig");

pub const version = @embedFile("version");

test {
    testing.refAllDeclsRecursive(parser);
    testing.refAllDeclsRecursive(assembler);
    testing.refAllDeclsRecursive(computer);
}
