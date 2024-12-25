import os

from sage.all import *

flag = open("flag.txt", "rb").read().strip(b"RS{}")
assert len(flag) == 192

while True:
    p = random_prime(1 << 513, lbound=1 << 512)
    coefs = [int.from_bytes(os.urandom(42), "big") for _ in range(8)]
    PR = PolynomialRing(GF(p), 'x')
    x = PR.gen()

    f = lambda g: sum(coefs[i] * x ** i for i in range(2 * g + 2))
    f1, f2 = f(2), f(3)

    flags = [GF(p)(int.from_bytes(flag[i:i + 64], "big")) for i in range(0, 192, 64)]
    flags.append(GF(p)(int.from_bytes(b"These are some of my recent thoughts. You are required to agree!", "big")))
    pol = lambda f, z: x * x - f(z)

    roots = [pol(f1, flags[0]).roots(), pol(f1, flags[1]).roots(), pol(f2, flags[2]).roots(), pol(f2, flags[3]).roots()]

    if any(not r for r in roots):
        continue

    HC = lambda f: HyperellipticCurve(f, 0).jacobian()(GF(p))
    J1, J2 = HC(f1), HC(f2)

    points = [HyperellipticCurve(f1)((flags[0], roots[0][0][0])), HyperellipticCurve(f1)((flags[1], roots[1][0][0])),
              HyperellipticCurve(f2)((flags[2], roots[2][0][0])), HyperellipticCurve(f2)((flags[3], roots[3][0][0]))]

    print(2 * J1(points[0]) + 2 * J1(points[1]))
    print(5 * J2(points[2]))
    print(J2(points[3]))
    break
