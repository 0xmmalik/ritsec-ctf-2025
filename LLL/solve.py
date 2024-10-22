from sage.all import Matrix, ZZ

# Truncated outputs (given in the challenge)
truncated_outputs = [64554, 51743, 18916, 64343, 31318, 39315, 9287, 30734, 60385, 54082, 10808, 6032, 21668, 33357, 63363, 62958, 32996, 51200, 62582, 49735, 4714, 2493, 10172, 21006, 44300, 53262, 57479, 30482, 56392, 7214, 48140, 28308, 24510, 57887, 25485, 18863, 9980, 48794, 60618, 41052]

# Known parameters
N = len(truncated_outputs)
modulus = 2**16  # 16-bit truncation

# Construct the lattice basis for LLL
def construct_lattice(truncated_outputs, modulus, num_states=40):
    M = Matrix(ZZ, num_states+1, num_states+1)
    for i in range(num_states):
        M[i, i] = modulus
        M[i, -1] = truncated_outputs[i]
    M[-1, -1] = 1
    return M

# Perform LLL reduction
def perform_lll(truncated_outputs, modulus):
    lattice = construct_lattice(truncated_outputs, modulus)
    reduced_lattice = lattice.LLL()
    return reduced_lattice

# Recover the internal state X_n (full 64-bit state)
def recover_lcg_state(reduced_lattice, modulus):
    recovered_states = []
    for row in reduced_lattice:
        potential_state = row[-1] % modulus
        recovered_states.append(potential_state)
    return recovered_states

# Solve the LCG using LLL
reduced_lattice = perform_lll(truncated_outputs, modulus)
recovered_states = recover_lcg_state(reduced_lattice, modulus)

print(f"Recovered LCG states: {recovered_states}")
