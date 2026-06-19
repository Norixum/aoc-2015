package aoc

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Reindeer :: struct {
    name: string,
    speed: int,
    flying_time: int,
    resting_time: int,
}

skip :: proc(words_iter: ^string, words_count: int) {
    for _ in 0..<words_count {
        strings.split_iterator(words_iter, " ")
    }
}

get_reindeers :: proc() -> [dynamic]Reindeer {
    bytes := os.read_entire_file("input.txt", context.allocator) or_else unreachable()
    content := string(bytes)

    reindeers: [dynamic]Reindeer
    lines_iter := content
    for {
        line, ok := strings.split_lines_iterator(&lines_iter)
        if !ok do break

        words_iter := line
        name, _ := strings.split_iterator(&words_iter, " ")
        skip(&words_iter, 2)
        speed_str, _ := strings.split_iterator(&words_iter, " ")
        speed, _ := strconv.parse_int(speed_str)
        skip(&words_iter, 2)
        flying_time_str, _ := strings.split_iterator(&words_iter, " ")
        flying_time, _ := strconv.parse_int(flying_time_str)
        skip(&words_iter, 6)
        resting_time_str, _ := strings.split_iterator(&words_iter, " ")
        resting_time, _ := strconv.parse_int(resting_time_str)

        append(&reindeers, Reindeer {
            name,
            speed,
            flying_time,
            resting_time,
        })
    }

    return reindeers
}

distance :: proc(reindeer: Reindeer, time: int) -> int {
    cycle_time := reindeer.flying_time + reindeer.resting_time
    if time % cycle_time <= reindeer.flying_time {
        return time / cycle_time * reindeer.flying_time * reindeer.speed +
               time % cycle_time * reindeer.speed
    }
    return (time / cycle_time + 1) * reindeer.flying_time * reindeer.speed
}

main :: proc() {
    reindeers := get_reindeers()
    time :: 2503
    best_distance := 0
    for reindeer in reindeers {
        d := distance(reindeer, time)
        if d > best_distance do best_distance = d
    }
    fmt.printfln("Part 1: %v", best_distance)

    points := make([]int, len(reindeers))
    distances := make([]int, len(reindeers))
    for t in 1..=time {
        best := 0
        for i in 0..<len(reindeers) {
            distances[i] = distance(reindeers[i], t)
            if distances[i] > best do best = distances[i]
        }
        for i in 0..<len(reindeers) {
            if distances[i] == best do points[i] += 1
        }
    }

    max_points := 0
    for p in points {
        if p > max_points do max_points = p
    }
    fmt.printfln("Part 2: %v", max_points)
}
