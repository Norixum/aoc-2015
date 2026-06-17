package aoc

import "core:fmt"
import "core:os"
import "core:math"
import "core:strings"
import "core:strconv"

Table :: struct {
    header: []string,
    body: []int,
}

create_happiness_table :: proc(path: string) -> Table {
    bytes := os.read_entire_file(path, context.allocator) or_else unreachable()
    content := string(bytes)

    // k - number of lines in file
    // n - number of people
    // 
    // n * (n - 1) = k
    // n^2 - n - k = 0
    // D = b^2 - 4*a*c
    // D = 1 - 4*1*(-k) = 1 + 4k (> 0)
    // n = (-b +- sqrt(D)) / (2*a)
    // n_1 = (-b + sqrt(D)) / (2*a) = (1 + sqrt(1 + 4k)) / 2 =
    //     = (1 + sqrt(1 + 4k)) / 2
    // n_2 = (1 - sqrt(1 + 4k)) / 2
    // sqrt(1 + 4k) > sqrt(1), if k > 0 => 1 + 4k > 1
    // therefore only n_1 is positive

    k: int
    for lines_iter := content; true; {
        line, ok := strings.split_lines_iterator(&lines_iter)
        if !ok do break
        if len(line) == 0 do break
        k += 1
    }
    n := int((1 + math.sqrt(1 + 4 * f32(k))) / 2)

    table: Table
    table.header = make([]string, n)
    table.body = make([]int, n*n)

    for lines_iter, i := content, 0; true; i += 1 {
        line, ok := strings.split_lines_iterator(&lines_iter)
        if !ok do break
        if len(line) == 0 do break

        name_end := strings.index(line, " ")
        name := line[:name_end]
        table.header[i] = name

        for _ in 0..<n - 2 {
            strings.split_lines_iterator(&lines_iter)
        }
    }

    for lines_iter := content; true; {
        line, ok := strings.split_lines_iterator(&lines_iter)
        if !ok do break
        if len(line) == 0 do break

        words_iter := line
        name1, _ := strings.split_iterator(&words_iter, " ")
        strings.split_iterator(&words_iter, " ")
        action, _ := strings.split_iterator(&words_iter, " ")
        amount_str, _ := strings.split_iterator(&words_iter, " ")
        for _ in 0..<6 {
            strings.split_iterator(&words_iter, " ")
        }
        name2, _ := strings.split_iterator(&words_iter, " ")
        name2 = name2[:len(name2) - 1] // remove dot

        name1_id := get_person_id(table, name1)
        name2_id := get_person_id(table, name2)
        id := name1_id * n + name2_id
        amount := strconv.parse_int(amount_str) or_else unreachable()
        if strings.compare(action, "gain") == 0 {
            table.body[id] = amount
        } else {
            table.body[id] = -amount
        }
     }

    return table
}

get_person_id :: proc(haystack: Table, needle: string) -> int {
    for person, i in haystack.header {
        if strings.compare(person, needle) == 0 do return i 
    }
    return -1
}

print_table :: proc(table: Table) {
    for name, i in table.header {
        fmt.printfln("%v: %v", i, name)
    }
    fmt.println()
    fmt.print("   ")
    n := len(table.header)
    for i in 0..<n {
        fmt.printf("% 4d", i)
    }
    fmt.println()
    for i in 0..<n {
        fmt.printf("%d  ", i)
        for j in 0..<n {
            fmt.printf("% 4d", table.body[i * n + j])
        }
        fmt.println()
    }
}

find_best_arrangement_happiness :: proc(table: Table) -> int {
    find_best_arrangement_happiness_impl :: proc(
        table: Table,
        people_ids: []int,
        arrangement: []int,
        max: int = min(int),
        seat: int = 0
    ) -> int {
        max := max
        if len(people_ids) == 0 {
            sum := 0
            for i in 0..<len(arrangement) {
                n := len(table.header)
                current := arrangement[i]
                left    := arrangement[(i - 1 + n) % n]
                right   := arrangement[(i + 1 + n) % n]
                id1 := current * n + left
                id2 := current * n + right
                sum += table.body[id1]
                sum += table.body[id2]
            }
            if sum > max do return sum
        }
        // All the same
        // 
        // 0 1 2 3
        // 1 2 3 0
        // 2 3 0 1
        // 3 0 1 2
        //
        // 3 2 1 0
        // 2 1 0 3
        // 1 0 3 2
        // 0 3 2 1
        // 
        // Because we are talking about circle,
        // starting point doesn't matter. Same with
        // going clockwise or counterclockwise.
        //
        // So we can reduce number of arrangements we
        // need to check from n! to n! / (2n) or (n - 1)! / 2.
        //
        // But I have no idea how to properly traverse
        // like that :)

        @(static) pool: [1024]int
        @(static) pool_count: int
        for id in people_ids {
            arrangement[seat] = id
            others_count := len(people_ids) - 1
            others := pool[pool_count:pool_count + others_count]
            pool_count += others_count
            defer pool_count -= others_count
            i := 0
            for id1 in people_ids {
                if id1 != id {
                    others[i] = id1
                    i += 1
                }
            }
            max = find_best_arrangement_happiness_impl(table, others, arrangement, max, seat + 1)
        }
        return max
    }

    people_ids := make([]int, len(table.header))
    for &id, i in people_ids { id = i }
    arrangement := make([]int, len(table.header))
    return find_best_arrangement_happiness_impl(table, people_ids, arrangement)
}

part1 :: proc(table: Table) {
    print_table(table)
    fmt.printfln("\nPart 1: %v\n", find_best_arrangement_happiness(table))
}

part2 :: proc(table: Table) {
    table := table
    old_header := table.header
    table.header = make([]string, len(old_header) + 1)
    copy(table.header, old_header)
    table.header[len(table.header) - 1] = "You"

    old_body := table.body
    n := len(table.header)
    table.body = make([]int, n*n)
    for i in 0..<n - 1 {
        for j in 0..<n - 1 {
            table.body[i * n + j] = old_body[i * (n - 1) + j]
        }
    }
    print_table(table)
    fmt.printfln("\nPart 2: %v\n", find_best_arrangement_happiness(table))
}

main :: proc() {
    table := create_happiness_table("input.txt")
    part1(table)
    part2(table)
}
