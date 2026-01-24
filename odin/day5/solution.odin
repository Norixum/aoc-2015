package aoc

import "core:fmt"
import "core:os"
import "core:strings"

part1 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")

    lines := strings.split(string(input), "\n")
    nice_strings_count := 0
    for line in lines {
        vowels_count := 0
        for i := 0; i < len(line); i += 1 {
            if strings.contains("aeiou", line[i:i + 1]) {
                vowels_count += 1
            }
        }
        if vowels_count < 3 do continue

        has_pair := false
        for i := 0; i < len(line) - 1; i += 1 {
            if line[i] == line[i + 1] {
                has_pair = true
                break
            }
        }
        if !has_pair do continue

        has_banned_string := false
        has_banned_string |= strings.contains(line, "ab")
        has_banned_string |= strings.contains(line, "cd")
        has_banned_string |= strings.contains(line, "pq")
        has_banned_string |= strings.contains(line, "xy")
        if has_banned_string do continue
        
        nice_strings_count += 1
    }

    fmt.println(nice_strings_count)
}

part2 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")

    lines := strings.split(string(input), "\n")
    nice_strings_count := 0
    for line in lines {
        contains_pair := false
        for i := 0; i < len(line) - 1; i += 1 {
            if strings.contains(line[i + 2:], line[i:i + 2]) {
                contains_pair = true
                break
            }
        }
        if !contains_pair do continue

        contains_repeat := false
        for i := 0; i < len(line) - 2; i += 1 {
            if line[i + 2] == line[i] {
                contains_repeat = true
                break
            }
        }
        if !contains_repeat do continue
        
        nice_strings_count += 1
    }

    fmt.println(nice_strings_count)
}

main :: proc() {
    // part1()
    part2()
}
