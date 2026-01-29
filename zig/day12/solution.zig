const std   = @import("std");
const ascii = std.ascii;
const fmt   = std.fmt;
const fs    = std.fs;
const mem   = std.mem;
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
    current: usize,

    pub fn new(content: []const u8) Parser {
        return .{
            .content = content,
            .current = 0,
        };
    }

    pub fn next(self: *Parser) ?u8 {
        if (self.*.current >= self.*.content.len) return null;
        const result = self.*.content[self.*.current];
        self.*.current += 1;
        return result;
    }
};

fn parseNumber(parser: *Parser) !i64 {
    const begin = parser.*.current - 1;
    while (parser.next()) |c| {
        if (ascii.isDigit(c)) continue;
        break;
    }
    parser.*.current -= 1;
    const number_str = parser.*.content[begin..parser.*.current];
    const number = try fmt.parseInt(i64, number_str, 10);
    return number;
}

fn parseString(parser: *Parser) []const u8 {
    const begin = parser.*.current;
    while (parser.next().? != '"') { }
    const end = parser.*.current - 1;
    return parser.*.content[begin..end];
}

fn parseObject(parser: *Parser) anyerror!i64 {
    var sum: i64 = 0;
    var has_red = false;
    while (true) {
        var char = parser.next().?;

        if (char == '}') break;
        std.debug.assert(char == '"');
        _ = parseString(parser);
        std.debug.assert(parser.next().? == ':');

        char = parser.next().?;
        switch (char) {
            '[' => sum += try parseArray(parser),
            '"' => {
                const name = parseString(parser);
                if (mem.eql(u8, name, "red")) has_red = true;
            },
            '{' => sum += try parseObject(parser),
            '-' => sum += try parseNumber(parser),
            '0'...'9' => sum += try parseNumber(parser),
            else => {
                print("Unknown char {c}\n", .{char});
                return error.UnknownChar;
            },
        }

        char = parser.next().?;
        if (char == '}') break;
        std.debug.assert(char == ',');
    }

    if (has_red) return 0;
    return sum;
}

fn parseArray(parser: *Parser) !i64 {
    var sum: i64 = 0;
    while (true) {
        const char = parser.next().?;
        switch (char) {
            ']' => return sum,
            '[' => sum += try parseArray(parser),
            '"' => _ = parseString(parser),
            ',' => continue,
            '{' => sum += try parseObject(parser),
            '-' => sum += try parseNumber(parser),
            '0'...'9' => sum += try parseNumber(parser),
            else => {
                print("Unknown char {c}\n", .{char});
                return error.UnknownChar;
            },
        }
    }
}

fn parse(input: []const u8) !i64 {
    var parser = Parser.new(input);
    const char = parser.next().?;
    switch (char) {
        '[' => return try parseArray(&parser),
        else => {
            print("Unknown char {c}\n", .{char});
            return error.UnknownChar;
        },
    }
}

fn part2(input: []const u8) !void {
    const sum = try parse(input);
    print("Part 2: {}\n", .{sum});
}

pub fn main() !void {
    const allocator = std.heap.smp_allocator;
    const input = try readInput(allocator);
    try part1(input);
    try part2(input);
}
