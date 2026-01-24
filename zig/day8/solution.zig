const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const print = std.debug.print;
const assert = std.debug.assert;

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
    var total: usize = 0;
    var lines_iter = mem.splitScalar(u8, input, '\n');
    while (lines_iter.next()) |line| {
        if (line.len == 0) break;
        var in_memory_length: usize = 0;
        var index: usize = 1;
        while (index < line.len - 1) : (index += 1) {
            in_memory_length += 1;
            if (line[index] != '\\') continue;
            index += 1;
            assert(index < line.len);
            if (line[index] == '\\') continue;
            if (line[index] == '"') continue;
            if (line[index] == 'x') {
                index += 2;
                assert(index < line.len);
                continue;
            }
            unreachable;
        }
        total += line.len - in_memory_length;
    }

    print("Part 1: {}\n", .{total});
}

fn part2(input: []u8) void {
    var total: usize = 0;
    var lines_iter = mem.splitScalar(u8, input, '\n');
    while (lines_iter.next()) |line| {
        if (line.len == 0) break;
        var in_code_length: usize = 2;
        var index: usize = 0;
        while (index < line.len) : (index += 1) {
            in_code_length += 1;
            if (line[index] == '\\' or line[index] == '"') {
                in_code_length += 1;
            }
        }
        total += in_code_length - line.len;
    }

    print("Part 2: {}\n", .{total});
}
