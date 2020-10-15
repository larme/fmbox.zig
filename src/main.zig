const std = @import("std");
const wav = @import("wav.zig");

const sr: u32 = 44100;

fn sample2phase(freq: f32, sample: usize) f32 {
    const srf = @as(f32, sr);
    const step = freq / srf;
    const raw_phase: f32 = step * @intToFloat(f32, sample);
    return @mod(raw_phase, 1.0);
}

fn convert(dst_int: []u8, src_flt: []const f32, amp: f32) void {
    const max_v = @as(f32, std.math.maxInt(i16));
    const mul: f32 = max_v * amp;

    var i: usize = 0;
    while (i < src_flt.len) : (i += 1) {
        const v = src_flt[i] * mul;

        // clipped value
        const cv = if (v <= -max_v)
            @as(i16, -max_v)
        else if (v >= max_v)
            @as(i16, max_v)
        else if (v != v) // NaN
            @as(i16, 0)
        else
            @floatToInt(i16, v);

        const idx = i * 2;
        dst_int[idx + 0] = @intCast(u8, cv & 0xFF);
        dst_int[idx + 1] = @intCast(u8, (cv >> 8) & 0xFF);
    }
}

pub fn main() !void {
    comptime const duration: i32 = 1;
    comptime const sn: i32 = sr * 1;

    var waveform: [sn]f32 = undefined;
    var data: [sn * 2]u8 = undefined;

    const x: f32 = 1.90;
    const out = std.math.sin(x);
    std.debug.print("sin is {}\n", .{out});

    const y: i16 = -1000;
    const y1: u8 = @intCast(u8, y & 0xFF);
    const y2: u8 = @intCast(u8, (y >> 8) & 0xFF);
    std.debug.print("haha {}, {}\n", .{ y1, y >> 8 & 0xFF });

    const z1: i8 = -3;
    const z2: u8 = @bitCast(u8, z1);
    std.debug.print("zzz {}, {}\n", .{ z1, z2 });

    const u: f32 = 2.315;
    std.debug.print("uuu {}\n", .{u % 1.0});

    std.debug.print("xixixi {}\n", .{sample2phase(440.0, 301)});

    const two_pi: f32 = std.math.pi * 2.0;
    for (waveform) |*p, sample| {
        const phase: f32 = sample2phase(440.0, sample);
        const v: f32 = std.math.sin(phase * two_pi);
        p.* = v;
    }

    convert(data[0..], waveform[0..], 0.5);
    std.debug.print("hahha {}\n", .{data[123]});

    std.debug.print("max int {}\n", .{std.math.maxInt(i16)});

    const file = try std.fs.cwd().createFile("out.wav", .{});
    defer file.close();
    var stream = file.outStream();
    const Saver = wav.Saver(@TypeOf(stream));

    try Saver.save(&stream, .{
        .num_channels = 1,
        .sample_rate = sr,
        .format = .signed16_lsb,
        .data = data[0..],
    });

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer {
    //     const leaked = gpa.deinit();
    //     if (leaked) expect(false); //fail test
    // }
}
