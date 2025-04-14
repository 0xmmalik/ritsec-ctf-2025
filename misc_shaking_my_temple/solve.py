from z3 import *

solver = Solver()

k = [BitVec(f'k_{i}', 8) for i in range(32)]

solver.add((k[0] ^ k[1]) + (k[2] * k[3]) == 232)
solver.add((k[4] * k[4] + k[5]) % 256 == k[6])
solver.add(k[7] + (k[8] * k[9]) == (k[10] * 5 + 10) % 100)
solver.add((k[11] ^ k[12]) + (k[13] * k[14]) == 200)
solver.add((k[16] + k[17]) % 37 == (k[18] * k[19]) % 90)
solver.add(k[20] * k[20] + k[21] * k[21] == 250)
solver.add(k[22] ^ (k[23] * 2) + (k[24] % 10) == 30)
solver.add(k[25] * k[26] == (k[27] ^ 20))
solver.add((k[28] + k[29]) ^ (k[30] - k[31]) == 15)

for i in range(32):
    solver.add(k[i] >= 32, k[i] <= 126)
    solver.add(Or(And(k[i] >= 48, k[i] <= 57), And(k[i] >= 65, k[i] <= 90), And(k[i] >= 97, k[i] <= 122)))

if solver.check() == sat:
    model = solver.model()
    key = ''.join([chr(model[k[i]].as_long()) for i in range(32)])
    print(f'Valid key: {key}, {len(key)}, {(model[k[20]].as_long() * model[k[20]].as_long() + model[k[21]].as_long() * model[k[21]].as_long())}')
else:
    print('No solution found.')
