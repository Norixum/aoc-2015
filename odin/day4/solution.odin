package aoc

import "core:fmt"
import "core:crypto/legacy/md5"
import "core:strconv"

mine_coin :: proc(cond: proc(hash: []u8) -> bool) {
    input := "bgvyzdsv"
    // input := "abcdef"

    buffer: [64]u8
    fmt.bprint(buffer[:], input)
    number_part := buffer[len(input):]

    ctx: md5.Context
    hash: [md5.DIGEST_SIZE]u8
    for i := 1; ; i += 1 {
        number_str := strconv.write_int(number_part, i64(i), 10)
        md5.init(&ctx)
        md5.update(&ctx, buffer[:len(input) + len(number_str)])
        md5.final(&ctx, hash[:])
        md5.reset(&ctx)

        if cond(hash[:]) {
            fmt.println(i)
            break
        }
    }
}

part1 :: proc() {
    cond :: proc(hash: []u8) -> bool {
        return hash[0] == 0 && hash[1] == 0 && hash[2] < 16
    }
    mine_coin(cond)
}

part2 :: proc() {
    cond :: proc(hash: []u8) -> bool {
        return hash[0] == 0 && hash[1] == 0 && hash[2] == 0
    }
    mine_coin(cond)
}

main :: proc() {
    // part1()
    part2()
}
