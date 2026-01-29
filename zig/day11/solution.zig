const std = @import("std");
const mem = std.mem;
const print = std.debug.print;

const Password = [8]u8;

fn incrementPassword(old_password: Password) Password {
    const base = 'z' - 'a' + 1;
    var new_password = old_password;
    var index = new_password.len - 1;
    var carry: u8 = 1;
    while (true) : (index -= 1) {
        const letter = new_password[index];
        const number = letter - 'a';
        const next = number + carry;
        new_password[index] = next % base + 'a';
        carry = next / base;
        if (index == 0 or carry == 0) break;
    }
    return new_password;
}

fn hasIncreasingStraight(password: Password) bool {
    var iterator = mem.window(u8, &password, 3, 1);
    while (iterator.next()) |window| {
        if (window[0] + 1 != window[1]) continue;
        if (window[1] + 1 != window[2]) continue;
        return true;
    }
    return false;
}

fn hasIOL(password: Password) bool {
    return mem.indexOfAny(u8, &password, "iol") != null;
}

fn hasTwoPairs(password: Password) bool {
    var first_pair_letter: ?u8 = null;
    var index: usize = 0;
    while (index < password.len - 1) : (index += 1) {
        const current = password[index];
        const next = password[index + 1];
        if (current != next) continue;
        index += 1;
        if (first_pair_letter == null) {
            first_pair_letter = current;
            continue;
        }
        if (first_pair_letter.? == current) continue;
        return true;
    }
    return false;
}

fn validatePassword(password: Password) bool {
    if (!hasIncreasingStraight(password)) return false;
    if (hasIOL(password)) return false;
    if (!hasTwoPairs(password)) return false;
    return true;
}

fn findNewPassword(password: Password) Password {
    var new_password = incrementPassword(password);
    while (!validatePassword(new_password)) {
        new_password = incrementPassword(new_password);
    }
    return new_password;
}

pub fn main() void {
    const input: Password = "hepxcrrq".*;
    const part1 = findNewPassword(input);
    print("Part 1: {s}\n", .{part1});
    const part2 = findNewPassword(part1);
    print("Part 2: {s}\n", .{part2});
}
