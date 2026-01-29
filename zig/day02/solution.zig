const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const print = std.debug.print;

pub fn main() !void {
    const file = try fs.cwd().openFile("./input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);
    _ = try file.read(buffer);

    try solve(buffer, 1);
    try solve(buffer, 2);
}

fn solve(input: []u8, part: u8) !void {
    var total: u64 = 0;
    var lines_iter = mem.splitScalar(u8, input[0..input.len - 1], '\n');
    while (lines_iter.next()) |line| {
        var dimensions_iter = mem.splitScalar(u8, line, 'x');
        const ls = dimensions_iter.next().?;
        const ws = dimensions_iter.next().?;
        const hs = dimensions_iter.next().?;
        const l = try fmt.parseInt(u64, ls, 10);
        const w = try fmt.parseInt(u64, ws, 10);
        const h = try fmt.parseInt(u64, hs, 10);
        switch (part) {
            1 => {
                total += 2*l*w + 2*w*h + 2*h*l;
                total += @min(l*w, w*h, h*l);
            },
            2 => {
                total += @min(2*(l+w), 2*(w+h), 2*(h+l));
                total += l*w*h;
            },
            else => unreachable,
        }
    }
    print("Part {}: {}\n", .{part, total});
}
