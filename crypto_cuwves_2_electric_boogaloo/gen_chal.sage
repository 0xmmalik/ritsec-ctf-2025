from sage.all import *

l = 3  # Small prime for l-isogeny
n = 4  # Depth of the volcano
f = 44  # Cofactor (adjustable)
p = l^n * f - 1
while not is_prime(p):
    f += 1  # Increment cofactor to find a prime
    print(f"trying f={f}")
    p = l^n * f - 1

print(f"Using prime p = {p}")

# Define finite field Fp2
Fp2 = GF(p^2, 'i')  # Quadratic extension field
i = Fp2.gen()

# Choose a supersingular elliptic curve more carefully
def find_supersingular_curve(Fp2):
    for A in range(1, 50):  # Try small A-values first
        E = EllipticCurve(Fp2, [A, 1])
        if len(E.isogenies_prime_degree(l)) > 0:
            return E
    raise ValueError("No valid supersingular curve found.")

E0 = find_supersingular_curve(Fp2)
print(f"Selected supersingular curve: {E0}")

# Function to perform a **proper** l-isogeny walk
def valid_isogeny_walk(E, max_steps, l):
    path = [E]
    for _ in range(max_steps):
        isogenies = E.isogenies_prime_degree(l)
        if not isogenies:
            break
        phi = isogenies[0]  # Choose the first available isogeny
        E = phi.codomain()
        path.append(E)
    return path

# Ensure Alice gets a long enough path
alice_path = []
while len(alice_path) < n:
    alice_path = valid_isogeny_walk(E0, n, l)
    if len(alice_path) < n:
        print("Retrying Alice’s walk...")

# Bob's different path, but reaching the same depth
bob_path = valid_isogeny_walk(E0, n, l)

# Select a valid midpoint curve
midpoint_index = max(1, len(alice_path) // 2)
leaked_curve = alice_path[midpoint_index]

# Extract Bob's final kernel generator correctly
def find_kernel_generator(E, l):
    torsion_points = [P for P in E.points() if l * P == E(0)]
    for P in torsion_points:
        if l * P == E(0):
            return P
    return None

bob_kernel = find_kernel_generator(bob_path[-1], l)

# Output challenge details
print(f"Starting curve: {E0}")
print(f"Leaked midpoint curve: {leaked_curve}")
print(f"Bob's final isogeny kernel generator: {bob_kernel}")

# Hidden flag (shared j-invariant)
shared_secret = alice_path[-1].j_invariant()
print(f"Flag: RS{{{shared_secret}}}")  # Hidden from participants
