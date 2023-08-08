const version = @import("zig_minion").version;

const utils = @import("utils.zig");

const INFO_TEXT =
    \\zig_minion
    \\     repo: https://github.com/tomBoddaert/zig_minion
    \\   author: Tom Boddaert (https://tomboddaert.com/)
    \\  version: {s}
;

pub fn run(comptime Writer: type, app: *utils.App(Writer)) void {
    utils.print(Writer, &app.stdout, INFO_TEXT, .{version});
}
