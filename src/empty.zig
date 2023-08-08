const utils = @import("utils.zig");

const NO_SUBCOMMAND_TEXT =
    \\No subcommand provided!
    \\  Run '{s} help' to get help!
    \\
;

pub fn run(comptime Writer: type, app: *utils.App(Writer)) void {
    utils.print(Writer, &app.stderr, NO_SUBCOMMAND_TEXT, .{app.command});
}
