package aoc

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

part1 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")
    lines := strings.split(string(input), "\n")

    total := 0
    for line in lines[:len(lines) - 1] {
        dimensions := strings.split(line, "x")
        l, _ := strconv.parse_int(dimensions[0])
        w, _ := strconv.parse_int(dimensions[1])
        h, _ := strconv.parse_int(dimensions[2])

        total += 2*l*w + 2*w*h + 2*h*l
        total += min(l*w, w*h, h*l)
    }

    fmt.println(total)
}

main :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")
    lines := strings.split(string(input), "\n")

    total := 0
    for line in lines[:len(lines) - 1] {
        dimensions := strings.split(line, "x")
        l, _ := strconv.parse_int(dimensions[0])
        w, _ := strconv.parse_int(dimensions[1])
        h, _ := strconv.parse_int(dimensions[2])

        total += min(2*l+2*w, 2*w+2*h, 2*l+2*h)
        total += l*w*h
    }

    fmt.println(total)
}
