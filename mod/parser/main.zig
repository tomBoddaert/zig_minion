const mem = @import("std").mem;

pub const instruction = @import("instruction/main.zig");
const Instruction = instruction.Instruction;

pub const Error = error{
    TooManyInstructions,
} || instruction.Error;

/// Assembly parser.
pub const Parser = struct {
    n_parsed: u7,
    parsed: [100]Instruction,

    /// Create an empty parser.
    pub inline fn new() @This() {
        return .{ .n_parsed = 0, .parsed = undefined };
    }

    /// Parse one line.
    pub fn parse(self: *@This(), line: []const u8) Error!void {
        const inst = try Instruction.parse(line) orelse return;

        if (self.n_parsed >= 100) return error.TooManyInstructions;

        self.parsed[self.n_parsed] = inst;
        self.n_parsed += 1;
    }

    /// Create a new parser and parse the input string.
    pub fn from_str(str: []const u8) Error!@This() {
        var parser = @This().new();
        var iter = mem.splitAny(u8, str, "\n\r");

        while (iter.next()) |line| try parser.parse(line);

        return parser;
    }

    /// Resolve the labels in the data portion of an instruction.
    pub fn resolve_labels(self: *@This()) Error!void {
        outer: for (self.parsed[0..self.n_parsed]) |*inst| {
            const label = switch (inst.data) {
                .Label => inst.data.Label,
                else => continue,
            };

            for (self.parsed[0..self.n_parsed], 0..) |inst2, index|
                if (mem.eql(u8, inst2.label orelse continue, label)) {
                    inst.data = .{ .Number = @truncate(index) };
                    continue :outer;
                };

            return error.NoMatchingLabel;
        }
    }
};

test {
    const testing = @import("std").testing;

    try testing.expectEqual(0, comptime Parser.new().n_parsed);

    const program_str =
        \\ # This example outputs some of the Van Eck sequence
        \\ #  (https://oeis.org/A181391)
        \\ # Use the 'Run' button above to run it
        \\ 
        \\ loop    LDA current     # load and output the current value
        \\         OUT
        \\ 
        \\         ADD base_a      # translate that to the value's index address
        \\         STO c_addr
        \\         LDA c_addr
        \\ 
        \\         ADD sto_n       # make a store instruction from the index address
        \\         STO sto_c
        \\         ADD d_lda_n     # make a load instruction from the store instruction
        \\         STO lda_c
        \\ 
        \\         SUB lda_max     # make sure the index is not > 99 (not load > 599)
        \\         BRP exit
        \\ 
        \\         LDA counter     # increment the counter
        \\         ADD one
        \\         STO counter
        \\ 
        \\ lda_c   DAT 0           # (modified) load the last index of the current value
        \\         BRZ update      # if zero, skip to [update]
        \\ 
        \\         STO c_index     # calculate counter - last index
        \\         LDA counter
        \\         SUB c_index
        \\ 
        \\ update  STO current     # set as the next number
        \\ 
        \\         LDA counter     # load the counter
        \\ sto_c   DAT 0           # (modified) store as the last index of the (old) current number
        \\         BR loop         # go to the start of the loop
        \\ 
        \\ exit    HLT             # stop
        \\ 
        \\ # state
        \\ current DAT 0           # the current number
        \\ counter DAT 0           # the counter
        \\ c_addr  DAT 0           # the address of the last index of the current number
        \\ c_index DAT 0           # (cache) the last index of the current number
        \\ 
        \\ # constants
        \\ one     DAT 1
        \\ sto_n   DAT 300         # op code of STO
        \\ d_lda_n DAT 200         # op code of LDA - op code of STO
        \\ lda_max DAT 599         # max address + op code of LDA
        \\ 
        \\ # base for last index storage
        \\ base_a  DAT base        # index of the base
        \\ base    DAT 0
    ;
    const program = try Parser.from_str(program_str);
    try testing.expectEqual(program.n_parsed, 34);
    try testing.expectEqual(Instruction{ .label = null, .operation = .OUT, .data = .Empty }, program.parsed[1]);
}
