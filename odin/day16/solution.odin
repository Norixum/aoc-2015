package aoc

import "core:os"
import "core:strings"
import "core:strconv"
import "core:fmt"

Thing :: struct {
    name: string,
    amount: int,
}

check_part1 :: proc(things: []Thing) -> bool {
    for thing in things {
        switch {
        case strings.compare(thing.name, "children")    == 0: if thing.amount != 3 do return false
        case strings.compare(thing.name, "cats")        == 0: if thing.amount != 7 do return false
        case strings.compare(thing.name, "samoyeds")    == 0: if thing.amount != 2 do return false
        case strings.compare(thing.name, "pomeranians") == 0: if thing.amount != 3 do return false
        case strings.compare(thing.name, "akitas")      == 0: if thing.amount != 0 do return false
        case strings.compare(thing.name, "vizslas")     == 0: if thing.amount != 0 do return false
        case strings.compare(thing.name, "goldfish")    == 0: if thing.amount != 5 do return false
        case strings.compare(thing.name, "trees")       == 0: if thing.amount != 3 do return false
        case strings.compare(thing.name, "cars")        == 0: if thing.amount != 2 do return false
        case strings.compare(thing.name, "perfumes")    == 0: if thing.amount != 1 do return false
        case: unreachable()
        }
    }
    return true
}

check_part2 :: proc(things: []Thing) -> bool {
    for thing in things {
        switch {
        case strings.compare(thing.name, "children")    == 0: if thing.amount != 3 do return false
        case strings.compare(thing.name, "cats")        == 0: if thing.amount <= 7 do return false
        case strings.compare(thing.name, "samoyeds")    == 0: if thing.amount != 2 do return false
        case strings.compare(thing.name, "pomeranians") == 0: if thing.amount >= 3 do return false
        case strings.compare(thing.name, "akitas")      == 0: if thing.amount != 0 do return false
        case strings.compare(thing.name, "vizslas")     == 0: if thing.amount != 0 do return false
        case strings.compare(thing.name, "goldfish")    == 0: if thing.amount >= 5 do return false
        case strings.compare(thing.name, "trees")       == 0: if thing.amount <= 3 do return false
        case strings.compare(thing.name, "cars")        == 0: if thing.amount != 2 do return false
        case strings.compare(thing.name, "perfumes")    == 0: if thing.amount != 1 do return false
        case: unreachable()
        }
    }
    return true
}

main :: proc() {
    input_data := os.read_entire_file("./input.txt", context.allocator) or_else panic("Can't load input file")
    input_str := string(input_data)

    things: [3]Thing
    for i := 0; i < 500; i += 1 {
        line, _ := strings.split_lines_iterator(&input_str)
        strings.split_iterator(&line, " ")
        strings.split_iterator(&line, " ")

        for &thing in things {
            line = strings.trim_left_space(line)
            thing.name, _ = strings.split_iterator(&line, ":")
            line = strings.trim_left_space(line)
            amount_str, _ := strings.split_iterator(&line, ",")
            thing.amount, _ = strconv.parse_int(amount_str)
        }

        if check_part1(things[:]) {
            fmt.printfln("Part 1: %v", i + 1)
        }
        if check_part2(things[:]) {
            fmt.printfln("Part 2: %v", i + 1)
        }
    }
}
