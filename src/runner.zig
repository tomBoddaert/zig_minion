const std = @import("std");

const Computer = @import("zig_minion").computer.Computer;

const utils = @import("utils.zig");

pub fn run(comptime Writer: type, app: *utils.App(Writer), memory: [100]u10) void {
    var stdin = std.io.getStdIn().reader();

    var computer = Computer.new(memory);

    while (computer.state == .Running) {
        const state = computer.run();

        switch (state) {
            .AwaitingInput => take_input(Writer, app, &computer, &stdin),
            .AwaitingOutput => give_output(Writer, app, &computer),
            else => {},
        }
    }
}

fn take_input(
    comptime Writer: type,
    app: *utils.App(Writer),
    computer: *Computer,
    stdin: *std.fs.File.Reader,
) void {
    utils.print(
        Writer,
        &app.stdout,
        "> ",
        .{},
    );

    var buffer: [3]u8 = undefined;
    var buffer_stream = std.io.fixedBufferStream(&buffer);
    stdin.streamUntilDelimiter(buffer_stream.writer(), '\n', null) catch
        return utils.print(
        Writer,
        &app.stderr,
        "Number too large!\n",
        .{},
    );
    const input = std.fmt.parseInt(u10, &buffer, 10) catch
        return utils.print(
        Writer,
        &app.stderr,
        "Invalid number!\n",
        .{},
    );

    if (input > 999) return utils.print(
        Writer,
        &app.stderr,
        "Number too large!\n",
        .{},
    );

    computer.input(input) catch @panic("Input unexpected!");
}

fn give_output(
    comptime Writer: type,
    app: *utils.App(Writer),
    computer: *Computer,
) void {
    const output = computer.output() catch @panic("Output unexpected!");
    utils.print(
        Writer,
        &app.stdout,
        "{d}\n",
        .{output},
    );
}
