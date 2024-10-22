import hashlib
import random

m = 2 ** 64 - 59
a = 0x5DEECE66D
c = 11
s = random.randint(0, m - 1)


def lcg(xn, a, c, m):
    return (a * xn + c) % m


def trunc_lcg(x0, a, c, m, n=40, b=16):
    xn = x0
    out = []
    for _ in range(n):
        xn = lcg(xn, a, c, m)
        zn = xn % (2 ** b)
        out.append(zn)
    return out


trunc_out = trunc_lcg(s, a, c, m)

print(trunc_out)


def key(x0, a, c, m, k=50):
    xn = x0
    for _ in range(k):
        xn = lcg(xn, a, c, m)
    key = hashlib.sha256(str(xn).encode()).hexdigest()
    print(xn)
    return f"RC{{{key}}}"


flag = key(s, a, c, m)
print(flag)
