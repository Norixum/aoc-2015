package aoc

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:time"
import rl "vendor:raylib"

SIDE_LEN :: 1000

Op_Type :: enum {
    Turn_On,
    Turn_Off,
    Toggle,
}

Op :: struct {
    type: Op_Type,
    range_begin_x: int,
    range_begin_y: int,
    range_end_x: int,
    range_end_y: int,
}

parse_op :: proc(line: string) -> Op {
    line_iter := line
    op_string := strings.split_iterator(&line_iter, " ") or_else panic("Missing operation")
    op: Op
    switch {
    case strings.compare(op_string, "turn") == 0:
        subop_string := strings.split_iterator(&line_iter, " ") or_else panic("Missing suboperation")
        switch {
        case strings.compare(subop_string, "on") == 0:
            op.type = .Turn_On
        case strings.compare(subop_string, "off") == 0:
            op.type = .Turn_Off
        case: unreachable()
        }
    case strings.compare(op_string, "toggle") == 0:
        op.type = .Toggle            
    case: unreachable()
    }

    range_begin_string := strings.split_iterator(&line_iter, " ") or_else panic("Missing beggining of range")
    range_begin_iter := range_begin_string
    range_begin_x_string := strings.split_iterator(&range_begin_iter, ",") or_else panic("Missing x coordinate")
    op.range_begin_x = strconv.parse_int(range_begin_x_string) or_else panic("Invalid number")
    range_begin_y_string := strings.split_iterator(&range_begin_iter, ",") or_else panic("Missing y coordinate")
    op.range_begin_y = strconv.parse_int(range_begin_y_string) or_else panic("Invalid number")

    through_keyword_string := strings.split_iterator(&line_iter, " ") or_else panic("Missing through")
    assert(strings.compare(through_keyword_string, "through") == 0)

    range_end_string := strings.split_iterator(&line_iter, " ") or_else panic("Missing beggining of range")
    range_end_iter := range_end_string
    range_end_x_string := strings.split_iterator(&range_end_iter, ",") or_else panic("Missing x coordinate")
    op.range_end_x = strconv.parse_int(range_end_x_string) or_else panic("Invalid number")
    range_end_y_string := strings.split_iterator(&range_end_iter, ",") or_else panic("Missing y coordinate")
    op.range_end_y = strconv.parse_int(range_end_y_string) or_else panic("Invalid number")

    return op
}

part1 :: proc() {
    lights := make([]u8, SIDE_LEN * SIDE_LEN)

    rl.InitWindow(SIDE_LEN, SIDE_LEN, "Lights")

    image: rl.Image
    image.width = SIDE_LEN
    image.height = SIDE_LEN
    image.data = raw_data(lights)
    image.format = .UNCOMPRESSED_GRAYSCALE
    image.mipmaps = 1

    texture := rl.LoadTextureFromImage(image)

    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't load input file")
    input_string := string(input)
    for line in strings.split_lines_iterator(&input_string) {
        if len(line) == 0 do break

        op := parse_op(line)

        for y in op.range_begin_y..=op.range_end_y {
            for x in op.range_begin_x..=op.range_end_x {
                light := &lights[y*SIDE_LEN + x]
                switch op.type {
                case .Turn_On:
                    light^ = 255
                case .Turn_Off:
                    light^ = 0
                case .Toggle:
                    light^ = ~light^
                }
            }
        }

        rl.BeginDrawing()
        rl.UpdateTexture(texture, raw_data(lights))
        rl.DrawTexture(texture, 0, 0, rl.WHITE)
        rl.EndDrawing()

        time.sleep(100 * time.Millisecond)
    }

    lit_lights_count := 0
    for i in 0..<len(lights) {
        if lights[i] == 255 do lit_lights_count += 1
    }

    fmt.println("Part 1 answer:", lit_lights_count)
    save_as_pbm(lights, "./lights_part1.pbm")
}

part2 :: proc() {
    lights := make([]byte, SIDE_LEN * SIDE_LEN)

    input := os.read_entire_file_from_filename("./input.txt") or_else panic("Can't load input file")
    input_string := string(input)

    rl.InitWindow(SIDE_LEN, SIDE_LEN, "Lights")

    image: rl.Image
    image.width = SIDE_LEN
    image.height = SIDE_LEN
    image.data = raw_data(lights)
    image.format = .UNCOMPRESSED_GRAYSCALE
    image.mipmaps = 1

    texture := rl.LoadTextureFromImage(image)

    for line in strings.split_lines_iterator(&input_string) {
        if len(line) == 0 do break

        op := parse_op(line)

        for y in op.range_begin_y..=op.range_end_y {
            for x in op.range_begin_x..=op.range_end_x {
                light := &lights[y*SIDE_LEN + x]
                switch op.type {
                case .Turn_On:
                    light^ += 1
                case .Turn_Off:
                    if light^ > 0 do light^ -= 1
                case .Toggle:
                    light^ += 2
                }
            }
        }

        rl.BeginDrawing()
        rl.UpdateTexture(texture, raw_data(lights))
        rl.DrawTexture(texture, 0, 0, rl.WHITE)
        rl.EndDrawing()

        time.sleep(100 * time.Millisecond)
    }

    total_brightness := 0
    for i in 0..<len(lights) {
        total_brightness += cast(int)lights[i]
    }

    fmt.println("Part 2 answer:", total_brightness)
    save_as_pgm(lights, "./lights_part2.pgm")
}

save_as_pbm :: proc(lights: []u8, path: string) {
    begin := time.now()
    
    handle, err := os.open(path, os.O_WRONLY | os.O_CREATE, 0o644)
    if err != nil {
        fmt.printfln("Can't save file [%v]: %v", path, err)
        return
    }
    defer os.close(handle)

    os.write_string(handle, "P1\n1000 1000\n")
    buffer: [dynamic]u8
    defer delete(buffer)

    for y in 0..<SIDE_LEN {
        for x in 0..<SIDE_LEN {
            append(&buffer, lights[y*SIDE_LEN + x] == 0 ? '0' : '1')
            if x != SIDE_LEN - 1 {
                append(&buffer, ' ')
            }
        }
        append(&buffer, '\n')
    }
    os.write(handle, buffer[:])

    end := time.now()
    total_time := time.duration_seconds(time.diff(begin, end))
    fmt.printfln("Generated %v in %.2vs", path, total_time)
}

save_as_pgm :: proc(lights: []byte, path: string) {
    begin := time.now()
    
    handle, err := os.open(path, os.O_WRONLY | os.O_CREATE, 0o644)
    if err != nil {
        fmt.printfln("Can't save file [%v]: %v", path, err)
        return
    }
    defer os.close(handle)

    os.write_string(handle, "P2\n1000 1000\n255\n")
    buffer: [dynamic]u8
    defer delete(buffer)

    byte_buffer: [3]u8
    for y in 0..<SIDE_LEN {
        for x in 0..<SIDE_LEN {
            light_string := fmt.bprintf(byte_buffer[:], "%v", lights[y*SIDE_LEN + x])
            append(&buffer, light_string)
            if x != SIDE_LEN - 1 {
                append(&buffer, ' ')
            }
        }
        append(&buffer, '\n')
    }
    os.write(handle, buffer[:])

    end := time.now()
    total_time := time.duration_seconds(time.diff(begin, end))
    fmt.printfln("Generated %v in %.2vs", path, total_time)
}

main :: proc() {
    // part1()
    part2()
}
