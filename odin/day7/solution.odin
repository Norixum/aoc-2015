package aoc

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

split_whitespace_iterator_or_die :: proc(s: ^string, loc := #caller_location) -> string {
    return strings.split_iterator(s, " ") or_else fmt.panicf("Failed in string splitting: %v", loc)
}

get_wire_value :: proc(cache: ^map[string]u16, wires: map[string]Op, wire: string) -> u16 {
    if value, ok := strconv.parse_u64(wire); ok {
        return u16(value)
    }

    if wire in cache {
        return cache[wire]
    }

    op := wires[wire]
    v: u16
    switch op.kind {
    case .Assign:        
        v = get_wire_value(cache, wires, op.a)
    case .Not:
        v = ~get_wire_value(cache, wires, op.a)
    case .And:
        l := get_wire_value(cache, wires, op.a)
        r := get_wire_value(cache, wires, op.b)
        v = l & r
    case .Or:
        l := get_wire_value(cache, wires, op.a)
        r := get_wire_value(cache, wires, op.b)
        v = l | r
    case .LShift:
        l := get_wire_value(cache, wires, op.a)
        r := get_wire_value(cache, wires, op.b)
        v = l << r
    case .RShift:
        l := get_wire_value(cache, wires, op.a)
        r := get_wire_value(cache, wires, op.b)
        v = l >> r
    case:
        unreachable()
    }

    cache[wire] = v
    return v
}

Op_Kind :: enum {
    Assign,
    Not,
    And,
    Or,
    LShift,
    RShift,
}

Op :: struct {
    kind: Op_Kind,
    a: string,
    b: string,
}

op_assign :: proc(a: string) -> Op {
    return {.Assign, a, {}}
}

op_not :: proc(a: string) -> Op {
    return {.Not, a, {}}
}

op_and :: proc(a, b: string) -> Op {
    return {.And, a, b}
}

op_or :: proc(a, b: string) -> Op {
    return {.Or, a, b}
}

op_lshift :: proc(a, b: string) -> Op {
    return {.LShift, a, b}
}

op_rshift :: proc(a, b: string) -> Op {
    return {.RShift, a, b}
}

parse_input :: proc(input: string) -> map[string]Op {
    wires: map[string]Op
    input_iter := input
    for line in strings.split_lines_iterator(&input_iter) {
        line_iter := line
        first := split_whitespace_iterator_or_die(&line_iter)

        if strings.compare(first, "NOT") == 0 {
            a := split_whitespace_iterator_or_die(&line_iter)
            arrow := split_whitespace_iterator_or_die(&line_iter)
            assert(strings.compare(arrow, "->") == 0)
            b := split_whitespace_iterator_or_die(&line_iter)
            wires[b] = op_not(a)
        } else {
            a := first
            second := split_whitespace_iterator_or_die(&line_iter)
            if strings.compare(second, "->") == 0 {
                b := split_whitespace_iterator_or_die(&line_iter)
                wires[b] = op_assign(a)
            } else {
                op := second
                b := split_whitespace_iterator_or_die(&line_iter)
                arrow := split_whitespace_iterator_or_die(&line_iter)
                assert(strings.compare(arrow, "->") == 0)
                c := split_whitespace_iterator_or_die(&line_iter)

                switch {
                case strings.compare(op, "AND") == 0:
                    wires[c] = op_and(a, b)
                case strings.compare(op, "OR") == 0:
                    wires[c] = op_or(a, b)
                case strings.compare(op, "LSHIFT") == 0:
                    wires[c] = op_lshift(a, b)
                case strings.compare(op, "RSHIFT") == 0:
                    wires[c] = op_rshift(a, b)
                case: unreachable()
                }
            }
        }
    }
    return wires
}

part1 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")
    wires := parse_input(cast(string)input[:len(input) - 1])
    fmt.printfln("Done parsing, get %v wires", len(wires))
    cache: map[string]u16
    fmt.printfln("Part 1 answer: %v", get_wire_value(&cache, wires, "a"))
}

part2 :: proc() {
    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't read input file")
    wires := parse_input(cast(string)input[:len(input) - 1])
    fmt.printfln("Done parsing, get %v wires", len(wires))
    cache: map[string]u16
    a := get_wire_value(&cache, wires, "a")
    wires["b"] = op_assign(fmt.aprint(a))
    clear(&cache)
    fmt.printfln("Part 2 answer: %v", get_wire_value(&cache, wires, "a"))
}


main :: proc() {
    // part1()
    part2()
}
