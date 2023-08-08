const std = @import("std");
const ascii = std.ascii;
const mem = std.mem;

pub const operation = @import("operation.zig");
const Operation = operation.Operation;
pub const data = @import("data.zig");
const Data = data.Data;
const WordIter = @import("../../utils/main.zig").WordIterator;

pub const Error = error{
    InvalidOperation,
    UnexpectedData,
    ExpectedData,
    NoMatchingLabel,
} || data.Error;

/// An instruction.
pub const Instruction = struct {
    label: ?[]const u8,
    operation: Operation,
    data: data.Data,

    /// Parse a string line, may return `null` if the line was empty or only contained a comment.
    pub fn parse(str: []const u8) Error!?@This() {
        var code = mem.sliceTo(str, ';');
        code = mem.sliceTo(code, '#');

        var iter = WordIter.new(code);

        var label: ?[]const u8 = null;
        var op: ?Operation = null;
        var dat: Data = .Empty;

        const first = iter.next() orelse return null;
        if (Operation.parse(first)) |parsed_op|
            op = parsed_op
        else
            label = first;

        const second = iter.next();
        if (op == null) {
            const parsed_op = Operation.parse(second orelse return error.InvalidOperation) orelse return error.InvalidOperation;
            op = parsed_op;
        } else if (second) |dat_str|
            dat = try Data.parse(dat_str);

        if (iter.next()) |third| {
            if (dat != .Empty) return error.UnexpectedData;

            dat = try Data.parse(third);
        }

        if (iter.next()) |_| return error.UnexpectedData;

        const inst = @This(){
            .label = label,
            .operation = op.?,
            .data = dat,
        };

        try inst.check_data();
        return inst;
    }

    /// Verify that the data in the instruction.
    pub inline fn check_data(self: @This()) Error!void {
        return self.operation.check_data(self.data);
    }
};

test {
    const testing = @import("std").testing;

    try testing.expectEqual(@as(?Instruction, null), try Instruction.parse(""));

    try testing.expectEqual(@as(
        ?Instruction,
        Instruction{ .label = null, .operation = Operation.HLT, .data = .Empty },
    ), try Instruction.parse("hlt"));
    try testing.expectEqual(@as(
        ?Instruction,
        Instruction{ .label = null, .operation = Operation.ADD, .data = .{ .Number = 50 } },
    ), try Instruction.parse("add 50"));
    const asm_1 = "loop in";
    try testing.expectEqual(@as(
        ?Instruction,
        Instruction{ .label = asm_1[0..4], .operation = Operation.IN, .data = .Empty },
    ), try Instruction.parse(asm_1));
    const asm_2 = "loop br end";
    try testing.expectEqual(@as(
        ?Instruction,
        Instruction{ .label = asm_2[0..4], .operation = Operation.BR, .data = .{ .Label = asm_2[8..11] } },
    ), try Instruction.parse(asm_2));

    try testing.expectError(error.InvalidOperation, Instruction.parse("invalid"));
    try testing.expectError(error.InvalidOperation, Instruction.parse("loop invalid"));
    try testing.expectError(error.UnexpectedData, Instruction.parse("add data invalid"));
    try testing.expectError(error.UnexpectedData, Instruction.parse("loop add data invalid"));
}
