const std = @import("std");
const ascii = std.ascii;

const instruction = @import("main.zig");

/// Instruction operations.
pub const Operation = enum(u4) {
    ADD,
    SUB,
    STO,
    LDA,
    BR,
    BRZ,
    BRP,
    IN,
    OUT,
    HLT,
    DAT,

    /// Parse a string as an operation, will return `null` if the string is not an operation.
    pub inline fn parse(str: []const u8) ?@This() {
        return OperationStateMachine.parse(str).to_operation();
    }

    /// Verify that the given data is valid for the instruction.
    pub fn check_data(self: @This(), data: instruction.data.Data) instruction.Error!void {
        switch (self) {
            .ADD, .SUB, .STO, .LDA, .BR, .BRZ, .BRP => switch (data) {
                .Empty => return error.ExpectedData,
                .Number => if (data.Number > 99) return error.NumberTooLarge,
                .Label => {},
            },
            .IN, .OUT, .HLT => switch (data) {
                .Empty => {},
                else => return error.UnexpectedData,
            },
            .DAT => switch (data) {
                .Empty => return error.ExpectedData,
                else => {},
            },
        }
    }

    /// Get the op code for the operation.
    pub fn op_code(self: @This()) u10 {
        return switch (self) {
            .ADD => 100,
            .SUB => 200,
            .STO => 300,
            .LDA => 500,
            .BR => 600,
            .BRZ => 700,
            .BRP => 800,
            .IN => 901,
            .OUT => 902,
            .HLT => 0,
            .DAT => 0,
        };
    }
};

/// State machine for parsing operations.
pub const OperationStateMachine = enum(u5) {
    Empty,
    Invalid,

    A,
    AD,
    ADD,

    S,
    SU,
    SUB,

    ST,
    STO,

    L,
    LD,
    LDA,

    B,
    BR,

    BRP,

    BRZ,

    I,
    IN,

    O,
    OU,
    OUT,

    H,
    HL,
    HLT,

    D,
    DA,
    DAT,

    /// Add a character to the state machine.
    pub fn apply(self: @This(), char: u8) @This() {
        const lower = ascii.toLower(char);

        return switch (self) {
            .Empty => return switch (lower) {
                'a' => .A,
                's' => .S,
                'l' => .L,
                'b' => .B,
                'i' => .I,
                'o' => .O,
                'h' => .H,
                'd' => .D,
                else => .Invalid,
            },

            .A => return switch (lower) {
                'd' => .AD,
                else => .Invalid,
            },

            .AD => return switch (lower) {
                'd' => .ADD,
                else => .Invalid,
            },

            .S => return switch (lower) {
                'u' => .SU,
                't' => .ST,
                else => .Invalid,
            },

            .SU => return switch (lower) {
                'b' => .SUB,
                else => .Invalid,
            },

            .ST => return switch (lower) {
                'o' => .STO,
                else => .Invalid,
            },

            .L => return switch (lower) {
                'd' => .LD,
                else => .Invalid,
            },

            .LD => return switch (lower) {
                'a' => .LDA,
                else => .Invalid,
            },

            .B => return switch (lower) {
                'r' => .BR,
                else => .Invalid,
            },

            .BR => return switch (lower) {
                'p' => .BRP,
                'z' => .BRZ,
                else => .Invalid,
            },

            .I => return switch (lower) {
                'n' => .IN,
                else => .Invalid,
            },

            .O => return switch (lower) {
                'u' => .OU,
                else => .Invalid,
            },

            .OU => return switch (lower) {
                't' => .OUT,
                else => .Invalid,
            },

            .H => return switch (lower) {
                'l' => .HL,
                else => .Invalid,
            },

            .HL => return switch (lower) {
                't' => .HLT,
                else => .Invalid,
            },

            .D => return switch (lower) {
                'a' => .DA,
                else => .Invalid,
            },

            .DA => return switch (lower) {
                't' => .DAT,
                else => .Invalid,
            },

            else => .Invalid,
        };
    }

    /// Run the state machine on a string slice.
    pub fn parse(str: []const u8) @This() {
        var state = @This().Empty;

        for (str) |char| {
            state = state.apply(char);

            if (state == .Invalid) return state;
        }

        return state;
    }

    /// Convert the state to an operation, or `null` if the state is not a valid operation.
    pub fn to_operation(self: @This()) ?Operation {
        return switch (self) {
            .ADD => .ADD,
            .SUB => .SUB,
            .STO => .STO,
            .LDA => .LDA,
            .BR => .BR,
            .BRP => .BRP,
            .BRZ => .BRZ,
            .IN => .IN,
            .OUT => .OUT,
            .HLT => .HLT,
            .DAT => .DAT,

            else => null,
        };
    }
};

test {
    const testing = std.testing;

    try testing.expectEqual(@as(?Operation, null), comptime Operation.parse(""));

    try testing.expectEqual(@as(?Operation, .ADD), comptime Operation.parse("add"));
    try testing.expectEqual(@as(?Operation, .SUB), comptime Operation.parse("sub"));
    try testing.expectEqual(@as(?Operation, .STO), comptime Operation.parse("sto"));
    try testing.expectEqual(@as(?Operation, .LDA), comptime Operation.parse("lda"));
    try testing.expectEqual(@as(?Operation, .BR), comptime Operation.parse("br"));
    try testing.expectEqual(@as(?Operation, .BRP), comptime Operation.parse("brp"));
    try testing.expectEqual(@as(?Operation, .BRZ), comptime Operation.parse("brz"));
    try testing.expectEqual(@as(?Operation, .IN), comptime Operation.parse("in"));
    try testing.expectEqual(@as(?Operation, .OUT), comptime Operation.parse("out"));
    try testing.expectEqual(@as(?Operation, .HLT), comptime Operation.parse("hlt"));
    try testing.expectEqual(@as(?Operation, .DAT), comptime Operation.parse("dat"));

    try testing.expectEqual(@as(?Operation, null), comptime Operation.parse("ad"));
    try testing.expectEqual(@as(?Operation, null), comptime Operation.parse("addd"));
}
