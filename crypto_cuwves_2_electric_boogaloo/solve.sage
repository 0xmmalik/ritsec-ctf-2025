# SageMath script: Solver for CTF Challenge
from sage.all import *

# Given parameters
l = 3  # Small prime for l-isogeny
n = 4  # Depth of the volcano
p = 4049  # Given prime from challenge
Fp2 = GF(p ^ 2, 'i')  # Quadratic extension field
i = Fp2.gen()

# Given challenge data (from generator output)
E0 = EllipticCurve(Fp2, [3, 1])  # Starting supersingular curve
leaked_curve = EllipticCurve(Fp2, [243, 729])  # Midpoint curve
bob_kernel = E0(0, 1, 0)  # Bob's final kernel generator (point at infinity)

print(f"Starting curve: {E0}")
print(f"Leaked midpoint curve: {leaked_curve}")
print(f"Bob’s final isogeny kernel generator: {bob_kernel}")


# Function to perform l-isogeny walk from a given curve
def isogeny_walk(E, steps, l):
    path = [E]
    for _ in range(steps):
        isogenies = E.isogenies_prime_degree(l)
        if not isogenies:
            break
        phi = isogenies[0]  # Follow the first isogeny
        E = phi.codomain()
        path.append(E)
    return path


# Step 1: Generate all possible paths from the leaked midpoint
def reconstruct_alice_path(midpoint_curve, steps, l):
    queue = [(midpoint_curve, [])]  # (Current Curve, Path)

    while queue:
        E, path = queue.pop(0)

        if len(path) == steps:  # Found a full-length path
            return path

        for iso in E.isogenies_prime_degree(l):
            new_curve = iso.codomain()
            queue.append((new_curve, path + [new_curve]))

    return None  # Should never happen if structure is valid


# Step 2: Find Alice's final curve by brute-forcing all paths
alice_final_curve = reconstruct_alice_path(leaked_curve, n // 2, l)[-1]

# Step 3: Compute the shared j-invariant
shared_secret = alice_final_curve.j_invariant()

# 🎉 Print the recovered flag
print(f"Recovered Flag: RS{{{shared_secret}}}")
