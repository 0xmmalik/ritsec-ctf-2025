# RITSEC CTF 2025 Writeup — Shaking My Temple

#### Challenge Setup.
We have to meet a bunch of constraints to generate a key. If we submit a valid key to the server, we get the flag! The constraints, written out in a much easier-to-understand way, are:

- `(k[0] ^ k[1]) + (k[2] * k[3]) == 232`
- `(k[4] * k[4] + k[5]) % 256 == k[6]`
- `k[7] + (k[8] * k[9]) == (k[10] * 5 + 10) % 100`
- `(k[11] ^ k[12]) + (k[13] * k[14]) == 200`
- `(k[16] + k[17]) % 37 == (k[18] * k[19]) % 90)`
- `k[20] * k[20] + k[21] * k[21] == 250`
- `k[22] ^ (k[23] * 2) + (k[24] % 10) == 30`
- `k[25] * k[26] == (k[27] ^ 20)`
- `(k[28] + k[29]) ^ (k[30] - k[31]) == 15`

#### Solution.
The title is a clue! **S**haking **M**y **T**emple gives us the initialism SMT, as in satisfiability modulo theory solvers. We can easily write a script using Microsoft Research's [Z3 solver](https://github.com/Z3Prover/z3). A Python script to find one solution can be found at [`solve.py`](https://github.com/0xmmalik/ritsec-ctf-2025/blob/main/shaking%20my%20temple/solve.py) and to find multiple solutions, use [`solve_multi.py`](https://github.com/0xmmalik/ritsec-ctf-2025/blob/main/shaking%20my%20temple/solve_multi.py).