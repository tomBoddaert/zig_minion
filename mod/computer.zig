pub const InputError = error{
    NotAwaitingInput,
    NumberTooLarge,
};

pub const OutputError = error{
    NotAwaitingOutput,
};

pub const Computer = struct {
    state: State,
    memory: [100]u10,
    counter: usize,
    register: u10,
    negative_flag: bool,

    pub fn new(mem: [100]u10) @This() {
        return @This(){
            .state = .Running,
            .memory = mem,
            .counter = 0,
            .register = 0,
            .negative_flag = false,
        };
    }

    pub fn step(self: *@This()) State {
        if (self.state != .Running) return self.state;

        if (self.counter >= 100) {
            self.state = .ReachedEnd;
            return self.state;
        }

        const instruction = self.memory[self.counter];
        const op_code = instruction / 100;
        const data = instruction % 100;

        switch (op_code) {
            1 => {
                self.register = @truncate(
                    (@as(u16, self.register) + self.memory[data]) % 1000,
                );
            },
            2 => {
                var lhs = @as(u16, self.register);
                const rhs = self.memory[data];

                if (rhs > lhs) {
                    lhs += 1000;
                    self.negative_flag = true;
                } else {
                    self.negative_flag = false;
                }

                self.register = @truncate(lhs - rhs);
            },
            3 => self.memory[data] = self.register,
            5 => self.register = self.memory[data],
            6 => {
                self.counter = data;
                return self.state;
            },
            7 => if (self.register == 0) {
                self.counter = data;
                return self.state;
            },
            8 => if (!self.negative_flag) {
                self.counter = data;
                return self.state;
            },
            9 => switch (data) {
                1 => self.state = .AwaitingInput,
                2 => self.state = .AwaitingOutput,
                else => {
                    self.state = .ReachedInvalidInstruction;
                    return self.state;
                },
            },
            0 => self.state = .Halted,
            else => return self.state,
        }

        self.counter += 1;
        return self.state;
    }

    pub inline fn run(self: *@This()) State {
        while (self.step() == .Running) {}
        return self.state;
    }

    pub fn input(self: *@This(), inp: u10) InputError!void {
        if (self.state != .AwaitingInput) return error.NotAwaitingInput;
        if (inp > 999) return error.NumberTooLarge;

        self.register = inp;
        self.state = .Running;
    }

    pub fn output(self: *@This()) OutputError!u10 {
        if (self.state != .AwaitingOutput) return error.NotAwaitingOutput;

        self.state = .Running;
        return self.register;
    }

    pub fn reset(self: *@This()) void {
        self.state = .Running;
        self.counter = 0;
        self.register = 0;
        self.negative_flag = false;
    }
};

pub const State = enum {
    Running,
    AwaitingInput,
    AwaitingOutput,
    Halted,
    ReachedEnd,
    ReachedInvalidInstruction,

    pub fn is_terminal(self: @This()) bool {
        return switch (self) {
            .Running, .AwaitingInput, .AwaitingOutput => false,
            .Halted, .ReachedEnd, .ReachedInvalidInstruction => true,
        };
    }
};
