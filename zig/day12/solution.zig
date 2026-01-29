const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const ascii = std.ascii;
const fmt = std.fmt;
const print = std.debug.print;

fn readInput(allocator: mem.Allocator) ![]u8 {
    const file = try fs.cwd().openFile("./input.txt", .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const input = try allocator.alloc(u8, file_size);
    _ = try file.read(input);
    return input;
}

fn part1(input: []const u8) !void {
    var sum: i64 = 0;
    var index: usize = 0;
    while (index < input.len) : (index += 1) {
        const char = input[index];
        if (char != '-' and !ascii.isDigit(char)) continue;
        const begin = index;
        index += 1;
        while (index < input.len and ascii.isDigit(input[index]))
            index += 1;
        const number_str = input[begin..index];
        const number = try fmt.parseInt(i64, number_str, 10);
        sum += number;
    }
    print("Part 1: {}\n", .{sum});
}

const Parser = struct {
    content: []const u8,
    current: ?usize,

    pub fn new(content: []const u8) Parser {
        return .{
            .content = content,
            .current = null,
        };
    }

    pub fn nextChar(self: *Parser) ?u8 {
        if (self.*.current >= self.*.content.len) return null;
        self.*.current += 1;
        return self.*.content[self.*.current];
    }

    pub fn currentChar(self: *Parser) u8 {
        return self.*.content[self.*.current];
    }

    pub fn trimLeft(self: *Parser) void {
        while (true) : (self.*.current += 1) {
            if (self.*.current >= self.*.content.len) break;
            if (self.*.content[self.*.current] == ' ') continue;
            self.*.current -= 1;
            break;
        }
    }
};

// fn parseString(content: *[]const u8) !void {
    
// }

fn parseArray(content: *[]const u8) !void {
    content.* = mem.trimLeft(u8, content.*, " ");
    if (content.*[0] == '[') {
        content.* = content.*[1..];
        try parseArray(content);
    } else {
        print("Unknown char {c}\n", .{content.*[0]});
        return error.UnknownChar;
    }
}

fn parse(input: []const u8) !void {
    var parser = Parser.new(input);
    parser.trimLeft();
    const char = parser.nextChar().?;
    if (char == '[') {
        try parseArray(&parser);
    } else {
        print("Unknown char {c}\n", .{char});
        return error.UnknownChar;
    }
}

pub fn main() !void {
    const allocator = std.heap.smp_allocator;
    const input = try readInput(allocator);
    try part1(input);
    try parse(input);
}
