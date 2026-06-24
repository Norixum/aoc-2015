package aoc

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Ingredient :: struct {
    name       : string,
    capacity   : int,
    durability : int,
    flavour    : int,
    texture    : int,
    calories   : int,
}

parse_field :: proc(iter: ^string) -> int {
    iter^ = strings.trim_left_space(iter^)
    strings.split_iterator(iter, " ")
    field_str, _ := strings.split_iterator(iter, ",")
    field, _ := strconv.parse_int(field_str)
    return field
}

get_ingredients :: proc() -> [dynamic]Ingredient {
    bytes := os.read_entire_file("input.txt", context.allocator) or_else unreachable()
    content := string(bytes)

    ingredients: [dynamic]Ingredient
    lines_iter := content
    for {
        line, ok := strings.split_lines_iterator(&lines_iter)
        if !ok do break

        words_iter := line
        name, _ := strings.split_iterator(&words_iter, ":")

        capacity := parse_field(&words_iter)
        durability := parse_field(&words_iter)
        flavour := parse_field(&words_iter)
        texture := parse_field(&words_iter)
        calories := parse_field(&words_iter)

        append(&ingredients, Ingredient {
            name,
            capacity,
            durability,
            flavour,
            texture,
            calories,
        })
    }

    return ingredients
}

main :: proc() {
    ingredients := get_ingredients()
    assert(len(ingredients) == 4)
    best_score1 := 0
    best_score2 := 0
    for i in 0..=100 {
        for j in 0..=100 {
            for k in 0..=100 {
                i0 := ingredients[0]
                i1 := ingredients[1]
                i2 := ingredients[2]
                i3 := ingredients[3]
                m := (100 - i - j - k)
                capacity   := max(0, i0.capacity * i + i1.capacity * j + i2.capacity * k + i3.capacity * m)
                durability := max(0, i0.durability * i + i1.durability * j + i2.durability * k + i3.durability * m)
                flavour    := max(0, i0.flavour * i + i1.flavour * j + i2.flavour * k + i3.flavour * m)
                texture    := max(0, i0.texture * i + i1.texture * j + i2.texture * k + i3.texture * m)
                calories   := max(0, i0.calories * i + i1.calories * j + i2.calories * k + i3.calories * m)
                score := capacity * durability * flavour * texture
                best_score1 = max(score, best_score1)
                if calories != 500 do continue
                best_score2 = max(score, best_score2)
            }
        }
    }

    fmt.printfln("Part 1: %v", best_score1)
    fmt.printfln("Part 2: %v", best_score2)
}
