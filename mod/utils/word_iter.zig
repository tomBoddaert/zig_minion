const mem = @import("std").mem;

pub const Iterator = struct {
    internal: mem.SplitIterator(u8, mem.DelimiterType.any),

    /// Create a new word iterator from a string slice.
    pub fn new(str: []const u8) @This() {
        return @This(){ .internal = mem.splitAny(u8, str, " \t") };
    }

    /// Get the next word, or `null` if the iterator has been exhausted.
    pub fn next(self: *@This()) ?[]const u8 {
        while (self.internal.next()) |n| if (n.len != 0) return n;
        return null;
    }
};
