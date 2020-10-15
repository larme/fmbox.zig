const std = @import("std");
const dsp = @import("dsp.zig");
const ba = @import("basic.zig");

const DSPObj = dsp.DSPObj;
const DSPInnerTickReturnType = dsp.DSPInnerTickReturnType;

/// params 0: init_phase
/// in 0: freq 1: reset trig
/// out 0: phase
pub const Phasor = struct {
    const Self = @This();
    core: DSPObj,
    phase: f32 = 0.0,
    params: []const f32,

    pub fn init(params: []const f32) Self {
        var obj = DSPObj.init(2, 1, _tick);
        const init_phase = params[0];
        return Self{
            .core = obj,
            .params = params,
            .phase = init_phase,
        };
    }

    fn _tick(obj: *DSPObj, ins: []const f32, out_buf: []f32) DSPInnerTickReturnType {
        const self: *Self = @fieldParentPtr(Self, "core", obj);
        const freq = ins[0];
        const reset_trig = ins[1];
        const current_phase = self.phase;
        const inc_per_sample = freq / obj.ctx.sr;
        const raw_phase = current_phase + inc_per_sample;
        const new_phase = @mod(raw_phase, 1.0);
        self.phase = new_phase;
        obj.out_buf[0] = new_phase;
    }
};

/// in 0: phase
/// out 0: sin value
pub const Sin = struct {
    const Self = @This();
    core: DSPObj,

    pub fn init() Self {
        var obj = DSPObj.init(1, 1, _tick);
        return Self{
            .core = obj,
        };
    }

    fn _tick(obj: *DSPObj, ins: []const f32, out_buf: []f32) DSPInnerTickReturnType {
        const phase = ins[0];
        out_buf[0] = std.math.sin(2 * std.math.pi * phase);
    }
};

pub fn main() !void {
    const ps = [1]f32{0.0};
    var phasor_con = Phasor.init(ps[0..]);
    var phasor = &phasor_con.core;
    var sin_con = Sin.init();
    var sin = &sin_con.core;
    const objs = [_]*DSPObj{ &Phasor.init(ps[0..]).core, &Sin.init().core };
    var comb_con = ba.Pipe.init(objs[0..]);
    var comb = &comb_con.core;

    const ins = [2]f32{ 440.0, 0.0 };

    var outs: []const f32 = undefined;
    var out: f32 = undefined;

    outs = try phasor.tick(ins[0..]);
    out = outs[0];
    std.debug.print("phase now is {}\n", .{out});
    outs = try sin.tick(outs);
    out = outs[0];
    std.debug.print("sin now is {}\n", .{out});
    outs = try comb.tick(ins[0..]);
    out = outs[0];
    std.debug.print("comb now is {}\n", .{out});

    outs = try phasor.tick(ins[0..]);
    out = outs[0];
    std.debug.print("phase now is {}\n", .{out});
    outs = try sin.tick(outs);
    out = outs[0];
    std.debug.print("sin now is {}\n", .{out});
    outs = try comb.tick(ins[0..]);
    out = outs[0];
    std.debug.print("comb now is {}\n", .{out});

    outs = try phasor.tick(ins[0..]);
    out = outs[0];
    std.debug.print("phase now is {}\n", .{out});
    outs = try sin.tick(outs);
    out = outs[0];
    std.debug.print("sin now is {}\n", .{out});
    outs = try comb.tick(ins[0..]);
    out = outs[0];
    std.debug.print("comb now is {}\n", .{out});

    outs = try phasor.tick(ins[0..]);
    out = outs[0];
    std.debug.print("phase now is {}\n", .{out});
    outs = try sin.tick(outs);
    out = outs[0];
    std.debug.print("sin now is {}\n", .{out});
    outs = try comb.tick(ins[0..]);
    out = outs[0];
    std.debug.print("comb now is {}\n", .{out});

    outs = try phasor.tick(ins[0..]);
    out = outs[0];
    std.debug.print("phase now is {}\n", .{out});
    outs = try sin.tick(outs);
    out = outs[0];
    std.debug.print("sin now is {}\n", .{out});
    outs = try comb.tick(ins[0..]);
    out = outs[0];
    std.debug.print("comb now is {}\n", .{out});

    outs = try phasor.tick(ins[0..]);
    out = outs[0];
    std.debug.print("phase now is {}\n", .{out});
    outs = try sin.tick(outs);
    out = outs[0];
    std.debug.print("sin now is {}\n", .{out});
    outs = try comb.tick(ins[0..]);
    out = outs[0];
    std.debug.print("comb now is {}\n", .{out});
}
