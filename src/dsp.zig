const std = @import("std");

pub const DSPError = error{ InputNumberMismatch, ExceedMaxOutputNumber };
pub const DSPInnerTickReturnType = DSPError!void;
pub const DSPInnerTickFnType = fn (self: *DSPObj, ins: []const f32, out_buf: []f32) DSPInnerTickReturnType;

const DSPContext = struct { sr: f32 = 44100.0 };

pub var ctx = DSPContext{};

const global_out_num: usize = 4096;
var global_out_buf: [global_out_num]f32 = [1]f32{0.0} ** global_out_num;
var global_out_counter: usize = 0;

fn create_out_buf(out_n: usize) []f32 {
    const new_counter: usize = global_out_counter + out_n;
    var out_buf = global_out_buf[global_out_counter..new_counter];
    global_out_counter = new_counter;
    return out_buf;
}

pub const DSPObj = struct {
    const Self = @This();
    ctx: *DSPContext = &ctx,
    in_n: usize,
    out_n: usize,
    out_buf: []f32,
    counter: usize = 0,
    innerTickFn: DSPInnerTickFnType,

    pub fn init(in_n: usize, out_n: usize, comptime innerTickFn: DSPInnerTickFnType) Self {
        var out_buf = create_out_buf(out_n);
        return DSPObj{
            .in_n = in_n,
            .out_n = out_n,
            .out_buf = out_buf,
            .innerTickFn = innerTickFn,
        };
    }

    pub fn inc_counter(self: *Self) void {
        self.counter = self.counter + 1;
    }

    pub fn reset(self: *Self) void {
        self.counter = 0;
        for (self.core.out_buf) |*v| {
            v.* = 0.0;
        }
    }

    fn _check_ins(self: *Self, ins: []const f32) DSPError!void {
        if (ins.len != self.in_n) {
            return DSPError.InputNumberMismatch;
        }
    }

    pub fn tick(self: *Self, ins: []const f32) DSPError![]const f32 {
        try self._check_ins(ins);
        // fill output buffer
        try self.innerTickFn(self, ins, self.out_buf);
        self.inc_counter();
        return self.out_buf[0..];
        //const ret: []const f32 = self.out_buf[0..];
        //return ret;
    }
};

pub fn main() !void {
    std.debug.print("haha", .{});
}
