const utils = @import("utils.zig");

const HELP_TEXT =
    \\Usage: {s} <subcommand> <arguments...>
    \\
    \\Subcommands:
    \\  help
    \\    Display this message
    \\
    \\  assemble <in path> <out path>
    \\    Assemble the input file to a binary file
    \\
    \\  run <path>
    \\    Run a binary file
    \\
    \\  runasm <path>
    \\    Assemble the input file and run it
    \\
    \\  info
    \\    Display information about this package
    \\
;

pub fn run(comptime Writer: type, app: *utils.App(Writer)) void {
    utils.print(Writer, &app.stdout, HELP_TEXT, .{app.command});
}
