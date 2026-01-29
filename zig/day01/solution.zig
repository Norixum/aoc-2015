const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    const file = try fs.cwd().openFile("./input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);
    _ = try file.read(buffer);

    part1(buffer);
    part2(buffer);
}

fn part1(input: []u8) void {
    var floor: i64 = 0;    
    for (input) |c| {
        if (c == '(') floor += 1;
        if (c == ')') floor -= 1;
    }

    print("Part 1: {}\n", .{floor});
}

fn part2(input: []u8) void {
    var floor: i64 = 0;
    for (input, 0..) |c, i| {
        if (c == '(') floor += 1;
        if (c == ')') floor -= 1;
        if (floor == -1) {
            print("Part 2: {}\n", .{i + 1});
            return;
        }
    }
    unreachable;
}
