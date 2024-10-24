from z3 import *

solver = Solver()


def check_valid(key):
    assert len(key) == 32
    k = [BitVec(f'k_{i}', 8) for i in range(32)]
    for i in range(32): solver.add(k[i] == ord(key[i]))
    solver.add((k[0] ^ k[1]) + (k[2] * k[3]) == 232)
    solver.add((k[4] * k[4] + k[5]) % 256 == k[6])
    solver.add(k[7] + (k[8] * k[9]) == (k[10] * 5 + 10) % 100)
    solver.add((k[11] ^ k[12]) + (k[13] * k[14]) == 200)
    solver.add((k[16] + k[17]) % 37 == (k[18] * k[19]) % 90)
    solver.add(k[20] * k[20] + k[21] * k[21] == 250)
    solver.add(k[22] ^ (k[23] * 2) + (k[24] % 10) == 30)
    solver.add(k[25] * k[26] == (k[27] ^ 20))
    solver.add((k[28] + k[29]) ^ (k[30] - k[31]) == 15)

    assert solver.check() == sat


if __name__ == "__main__":
    key = input("Yarrr! Enter yer key to claim yer treasure!\n\n> ")
    try:
        check_valid(key)
        print("\nYarrrr matey! Here be yer booty! RITSEC{l04ds_and_l0ad5_0f_g0ld!}")
    except AssertionError:
        print("\nYarrrr matey! Ye be tryin to plunder my booty! To the plank with ye, ye scallywag!")
