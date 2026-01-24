package aoc

import "core:fmt"
import "core:os"

v2i :: [2]int

update_pos :: proc(pos: ^v2i, dir: u8) {
    switch dir {
    case '^': pos.y += 1
    case 'v': pos.y -= 1
    case '>': pos.x += 1
    case '<': pos.x -= 1
    }
}

part1 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")

    santa_pos: v2i
    visited_houses: map[v2i]struct{}
    visited_houses[santa_pos] = {}
    for dir in input {
        update_pos(&santa_pos, dir)
        visited_houses[santa_pos] = {}
    }

    houses_count := len(visited_houses)
    fmt.println(houses_count)
}

part2 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")

    santa_pos: v2i
    robo_santa_pos: v2i
    visited_houses: map[v2i]struct{}
    visited_houses[santa_pos] = {}
    for i := 0; i < len(input) - 1; i += 2 {
        update_pos(&santa_pos, input[i])
        visited_houses[santa_pos] = {}
        update_pos(&robo_santa_pos, input[i + 1])
        visited_houses[robo_santa_pos] = {}
    }

    houses_count := len(visited_houses)
    fmt.println(houses_count)
}

main :: proc() {
    // part1()
    part2()
}
