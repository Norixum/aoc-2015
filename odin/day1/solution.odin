package aoc

import "core:fmt"
import "core:os"

part1 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")
    defer delete(input)

    floor := 0
    for p in input {
        if p == '(' do floor += 1
        if p == ')' do floor -= 1
    }

    fmt.println(floor)
}

part2 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")
    defer delete(input)
    
    floor := 0
    for p, i in input {
        if p == '(' do floor += 1
        if p == ')' do floor -= 1
        if floor == -1 {
            fmt.println(i + 1)
            break
        }
    }
}

main :: proc() {
    // part1()
    part2()
}
