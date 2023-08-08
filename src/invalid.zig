const utils = @import("utils.zig");

const INVALID_TEXT =
    \\Invalid subcommand!
    \\  Run '{s} help' to get help!
    \\
;

pub fn run(comptime Writer: type, app: *utils.App(Writer)) void {
    utils.print(Writer, &app.stderr, INVALID_TEXT, .{app.command});
}
