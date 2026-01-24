const std    = @import("std");
const fmt    = std.fmt;
const fs     = std.fs;
const math   = std.math;
const mem    = std.mem;
const print  = std.debug.print;
const assert = std.debug.assert;

fn find(haystack: []const []const u8, needle: []const u8) ?usize {
    for (haystack, 0..) |candidate, index| {
        if (mem.eql(u8, candidate, needle)) return index;
    }
    return null;
}

fn getLocations(input: []u8, allocator: mem.Allocator) !std.ArrayList([]const u8) {
    var locations = std.ArrayList([]const u8).empty;
    var lines_iter = mem.splitScalar(u8, input, '\n');
    while (lines_iter.next()) |line| {
        if (line.len == 0) break;
        var fields_iter = mem.splitScalar(u8, line, ' ');
        const from = fields_iter.next().?;
        if (find(locations.items, from) == null) {
            try locations.append(allocator, from);
        }
        _ = fields_iter.next().?;
        const to = fields_iter.next().?;
        if (find(locations.items, to) == null) {
            try locations.append(allocator, to);
        }
    }
    return locations;
}

fn getDistances(input: []u8, locations: []const []const u8, allocator: mem.Allocator) ![]u64 {
    const size = locations.len;
    var distances = try allocator.alloc(u64, size*size);
    @memset(distances, 0);

    var lines_iter = mem.splitScalar(u8, input, '\n');
    while (lines_iter.next()) |line| {
        if (line.len == 0) break;

        var fields_iter = mem.splitScalar(u8, line, ' ');
        const from = fields_iter.next().?;
        const from_index = find(locations, from).?;

        _ = fields_iter.next().?;
        const to = fields_iter.next().?;
        const to_index = find(locations, to).?;

        _ = fields_iter.next().?;
        const distance_string = fields_iter.next().?;
        const distance = try fmt.parseInt(u64, distance_string, 10);

        const n = locations.len;
        const flat_index = from_index * n + to_index;
        distances[flat_index] = distance;
    }

    return distances;
}

fn getDistance(distances: []u64, from: usize, to: usize) u64 {
    const size = math.sqrt(distances.len);
    const row = @min(from, to);
    const column = @max(from, to);
    return distances[row * size + column];
}

fn readInput(allocator: mem.Allocator) ![]u8 {
    const file = try fs.cwd().openFile("./input.txt", .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const input = try allocator.alloc(u8, file_size);
    _ = try file.read(input);
    return input;
}

fn findRoute(distances: []u64, condition: *const fn(a: u64, b: u64) bool, allocator: mem.Allocator) !u64 {
    const size = math.sqrt(distances.len);
    const visited = try allocator.alloc(bool, size);
    var optimal_route_distance: ?u64 = null;
    for (0..size) |start_index| {
        var current_route_distance: u64 = 0;
        var from_index = start_index;
        @memset(visited, false);
        visited[from_index] = true;
        while (true) {
            var nearest_location_index: ?usize = null;
            for (0..size) |to_index| {
                if (visited[to_index]) continue;
                if (nearest_location_index == null) {
                    nearest_location_index = to_index;
                    continue;
                }
                const current_distance = getDistance(distances, from_index, to_index);
                const nearest_distance = getDistance(distances, from_index, nearest_location_index.?);
                if (condition(current_distance, nearest_distance)) {
                    nearest_location_index = to_index;
                }
            }

            if (nearest_location_index == null) break;
            visited[nearest_location_index.?] = true;
            const nearest_distance = getDistance(distances, from_index, nearest_location_index.?);
            current_route_distance += nearest_distance;
            from_index = nearest_location_index.?;
        }
        if (optimal_route_distance == null or condition(current_route_distance, optimal_route_distance.?)) {
            optimal_route_distance = current_route_distance;
        }
    }
    return optimal_route_distance.?;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input = try readInput(allocator);

    const locations = try getLocations(input, allocator);
    print("Locations:\n", .{});
    for (locations.items) |location| {
        print("  {s}\n", .{location});
    }

    const size = locations.items.len;
    const distances = try getDistances(input, locations.items, allocator);
    print("Distances matrix:\n", .{});
    for (0..size) |i| {
        for (0..size) |j| {
            print("{d:4}", .{distances[i * size + j]});
        }
        print("\n", .{});
    }

    try part1(distances, allocator);
    try part2(distances, allocator);
}

fn part1(distances: []u64, allocator: mem.Allocator) !void {
    const min = struct {
        fn min(a: u64, b: u64) bool {
            return a < b;
        }
    }.min;
    const route_distance = try findRoute(distances, &min, allocator);
    print("Part 1: {}\n", .{route_distance});
}

fn part2(distances: []u64, allocator: mem.Allocator) !void {
    const max = struct {
        fn max(a: u64, b: u64) bool {
            return a > b;
        }
    }.max;
    const route_distance = try findRoute(distances, &max, allocator);
    print("Part 2: {}\n", .{route_distance});
}
