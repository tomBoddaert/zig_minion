const mem = @import("std").mem;

const parser = @import("parser/main.zig");

pub const Error = error{
    LabelNotResolved,
};

/// Assemble a single instruction.
/// Any labels must be resolved first!
pub fn assemble_instruction(inst: parser.instruction.Instruction) Error!u10 {
    var memory = switch (inst.data) {
        .Empty => 0,
        .Number => inst.data.Number,
        .Label => return error.LabelNotResolved,
    };
    memory += inst.operation.op_code();
    return memory;
}

/// Assemble all the instructions in a parser.
/// Any labels must be resolved first!
pub fn assemble_parser(par: parser.Parser) Error![100]u10 {
    var memory = [1]u10{0} ** 100;

    for (par.parsed[0..par.n_parsed], 0..) |inst, index| {
        memory[index] = try assemble_instruction(inst);
    }

    return memory;
}

pub const FromStrError = Error || parser.Error;

/// Parse the string and assemble the instructions.
pub fn assemble_str(str: []const u8) FromStrError![100]u10 {
    var par = try parser.Parser.from_str(str);
    try par.resolve_labels();
    return assemble_parser(par);
}

test {
    const testing = @import("std").testing;

    const parser_1 = comptime par_block: {
        var par = parser.Parser{
            .n_parsed = 3,
            .parsed = parsed_block: {
                var parsed: [100]parser.instruction.Instruction = undefined;
                parsed[0] = parser.instruction.Instruction{
                    .label = "loop",
                    .operation = .IN,
                    .data = .Empty,
                };
                parsed[1] = parser.instruction.Instruction{
                    .label = "bp",
                    .operation = .BR,
                    .data = .{ .Label = "loop" },
                };
                parsed[2] = parser.instruction.Instruction{
                    .label = null,
                    .operation = .BR,
                    .data = .{ .Label = "bp" },
                };
                break :parsed_block parsed;
            },
        };
        try par.resolve_labels();
        break :par_block par;
    };
    try testing.expectEqual(@as(u10, 0), comptime parser_1.parsed[1].data.Number);
    try testing.expectEqual(@as(u10, 1), comptime parser_1.parsed[2].data.Number);
}
