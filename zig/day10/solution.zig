const std = @import("std");
const mem = std.mem;
const print = std.debug.print;

fn appendPart(allocator: mem.Allocator, next: *std.ArrayList(u8), digit: u8, count: i64) !void {
    const Static = struct { var buffer: [32]u8 = undefined; };
    const count_str = try std.fmt.bufPrint(&Static.buffer, "{}", .{count});
    try next.appendSlice(allocator, count_str);
    try next.append(allocator, digit);
}

fn lookAndSay(allocator: mem.Allocator, input: []const u8, iterations: usize) !std.ArrayList(u8) {
    var current = std.ArrayList(u8).empty;
    var next = std.ArrayList(u8).empty;
    defer next.clearAndFree(allocator);
    try current.appendSlice(allocator, input);

    for (0..iterations) |_| {
        var digit = current.items[0];
        var count: i64 = 0;
        for (current.items) |item| {
            if (item == digit) {
                count += 1;
            } else {
                try appendPart(allocator, &next, digit, count);
                digit = item;
                count = 1;
            }
        }
        try appendPart(allocator, &next, digit, count);

        mem.swap(@TypeOf(current), &current, &next);
        next.clearRetainingCapacity();
    }
    
    return current;
}

pub fn main() !void {
    const input = "1113122113";
    const allocator = std.heap.smp_allocator;

    const part1 = try lookAndSay(allocator, input, 40);
    print("Part 1: {}\n", .{part1.items.len});
    const part2 = try lookAndSay(allocator, input, 50);
    print("Part 2: {}\n", .{part2.items.len});
}
