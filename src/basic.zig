const std = @import("std");
const dsp = @import("dsp.zig");
const DSPObj = dsp.DSPObj;
const DSPError = dsp.DSPError;
const DSPInnerTickReturnType = dsp.DSPInnerTickReturnType;

pub const Pipe = struct {
    const Self = @This();
    core: DSPObj,
    objs: []const *DSPObj,

    pub fn init(objs: []const *DSPObj) Self {
        const in_n = objs[0].in_n;
        const out_n = objs[objs.len - 1].out_n;
        var obj = DSPObj.init(in_n, out_n, _tick);
        // avoid extra copy
        obj.out_buf = objs[objs.len - 1].out_buf;
        return Self{
            .core = obj,
            .objs = objs,
        };
    }

    fn _tick(obj: *DSPObj, ins: []const f32, out_buf: []f32) DSPInnerTickReturnType {
        const self: *Self = @fieldParentPtr(Self, "core", obj);
        var outs: []const f32 = ins;
        for (self.objs) |obj_ptr| {
            outs = try obj_ptr.tick(outs);
        }
    }
};

pub fn main() !void {
    const o = dsp.DSPObjCore.init(3, 4);
    std.debug.print("in_n: {} out_n: {} buf len {}\n", .{ o.in_n, o.out_n, o.out_buf.len });
}
