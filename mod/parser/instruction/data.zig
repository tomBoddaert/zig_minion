const std = @import("std");
const ascii = std.ascii;

pub const Error = error{
    NumberTooLarge,
    InvalidNumber,
};

/// Types of instruction data.
pub const DataType = enum(u2) { Empty, Number, Label };

/// Instruction data.
pub const Data = union(DataType) {
    Empty: void,
    Number: u10,
    Label: []const u8,

    fn parse_num(str: []const u8) Error!Data {
        var data: u10 = 0;
        var digits: u2 = 0;

        for (str) |char| {
            if (digits >= 3) return error.NumberTooLarge;
            if (!ascii.isDigit(char)) return error.InvalidNumber;

            data *= 10;
            data += char - '0';

            digits += 1;
        }

        return .{ .Number = data };
    }

    /// Parse a string slice of instruction data.
    pub fn parse(str: []const u8) Error!Data {
        if (str.len == 0) return .Empty;

        if (ascii.isDigit(str[0])) return parse_num(str);

        return .{ .Label = str };
    }
};

test {
    const testing = std.testing;

    const empty = "";

    const short_number = "5";
    const long_number = "123";
    const invalid_number = "5a";
    const longer_number = "1234";

    const label = "abcd";
    const label_with_number = "ab5d";

    try testing.expectEqual(Data.Empty, try Data.parse(empty));

    try testing.expectEqual(Data{ .Number = 5 }, try Data.parse(short_number));
    try testing.expectEqual(Data{ .Number = 123 }, try Data.parse(long_number));
    try testing.expectError(error.InvalidNumber, Data.parse(invalid_number));
    try testing.expectError(error.NumberTooLarge, Data.parse(longer_number));

    try testing.expectEqual(Data{ .Label = label }, try Data.parse(label));
    try testing.expectEqual(Data{ .Label = label_with_number }, try Data.parse(label_with_number));
}
