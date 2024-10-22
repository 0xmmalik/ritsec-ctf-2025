# RITSEC CTF 2025 Writeup — cuwves <3

#### Challenge Setup.
- A prime `p` is generated and coefficients for two hyperelliptic curves `f1` and `f2` are selected. The flag, split into parts, is encoded into finite field elements, which are used to form the roots of polynomials.
- The challenge iterates through a loop, ensuring that valid roots exist for the polynomials defined by `f1` and `f2` (or it restarts).
- After validating the roots, points are computed on the Jacobians of the two curves, with operations performed on them (multiplication, addition).

#### Solution.
The first thing we need to do is recover the value of the prime `p`. We can do this pretty easily given the fact that we have the bytes used to create the third curve, `b'These are some of my recent thoughts. You are required to agree!'`. Now, we can factor to determine `p`:

```sage
x, y = var('x y')

C3 = (x + 12795775097566290830791524297570552333858566861521632899068855419137423580888786061735247095448452970812269447320737281114654933941269135753324751393302322, y + 7597235860561107976460153421520202657580734319928723809549567925690039059654966803132807917057053958118084576817237095249233512808198732598995402073933741)
txt = int.from_bytes(b"These are some of my recent thoughts. You are required to agree!", "big")

print(factor(C3[0](x=txt)))
```

This gives us `p=17216570189694800463910705256589709556098544199557118122584770957513536769680657330070489864431723793890082855088816237801416471002721833394911369948564563`. So now, we can go on to do lots of fun and cool math! We can handle the lattice challenge by solving a Closest Vector Problem (CVP) and using Babai's rounding method. CVP involves finding a lattice vector that is closest to a given target point. This method allows us to search for a solution that satisfies the flag equation, solving for specific values in the lattice.

Babai’s algorithm approximates the solution to CVP by projecting the target vector onto a reduced basis of the lattice and using a Gram-Schmidt orthogonalization process to round to the nearest lattice point. 

```sage
def Babai_CVP(mat, target):
    M = IntegerLattice(mat, lll_reduce=True).reduced_basis
    G = M.gram_schmidt()[0]
    diff = target
    for i in reversed(range(G.nrows())):
        diff -= M[i] * ((diff * G[i]) / (G[i] * G[i])).round()
    return target - diff
```
Now, we can write a `solve` function to handle a system of inequalities defined by the lattice. By adjusting the bounds and applying weight to the inequalities, we solve the system, giving us symbolic polynomial representations of `f1` and `f2`.

```sage
def solve(M, lbounds, ubounds, weight=None):
    mat, lb, ub = copy(M), copy(lbounds), copy(ubounds)
    num_var, num_ineq = mat.nrows(), mat.ncols()
    max_element = max(abs(mat[i, j]) for i in range(num_var) for j in range(num_ineq))

    weight = weight or num_ineq * max_element
    if len(lb) != num_ineq or len(ub) != num_ineq or any(lb[i] > ub[i] for i in range(num_ineq)):
        return

    DET = abs(mat.det()) if num_var == num_ineq else 0
    if DET:
        num_sol = (prod(ub[i] - lb[i] for i in range(num_ineq)) // DET) + 1
        print("Expected Number of Solutions:", num_sol)

    max_diff = max(ub[i] - lb[i] for i in range(num_ineq))
    applied_weights = [(weight if lb[i] == ub[i] else max_diff // (ub[i] - lb[i])) for i in range(num_ineq)]

    for i, w in enumerate(applied_weights):
        for j in range(num_var):
            mat[j, i] *= w
        lb[i] *= w
        ub[i] *= w

    target = vector((lb[i] + ub[i]) // 2 for i in range(num_ineq))
    result = Babai_CVP(mat, target)

    if any(not (lb[i] <= result[i] <= ub[i]) for i in range(num_ineq)):
        print("Fail: inequality does not hold after solving")

    fin = mat.transpose().solve_right(result) if DET else None
    return result, applied_weights, fin
```

Now, let's recover the flag. The flag is encoded in the polynomial coefficients,so using the hyperelliptic curve polynomials, we can perform symbolic operations to match the form of the flag with known polynomial equations. For the third part of the flag, `flag3`, we perform symbolic operations to compute a relation between the polynomial `f2`, the known curve, and a shifted version of the Jacobian point.

```sage
v_bar_flag3 = -V2.subs({x: X_flag3}) + (A + B * X_flag3) * U2.subs({x: X_flag3})
f2symbpol_flag3 = sum([GF(p)(ele) * X_flag3 ^ i for i, ele in enumerate(f2.list())])
lefthand = f2symbpol_flag3 - v_bar_flag3 ^ 2
righthand = -B ^ 2 * (X_flag3 - a) ^ 5 * U2.subs({x: X_flag3})
```
Using Groebner basis reduction and solving the system over a finite field, we can extract `flag3`.

```sage
I_flag3 = polsymbrng_flag3.ideal(equ)
V_flag3 = I_flag3.variety()
flag3_root = V_flag3[0][a]
flag3 = int.to_bytes(int(flag3_root.lift()), 64, 'big')
```

Similarly, `flag1` and `flag2` are extracted by solving their corresponding polynomial systems using Groebner basis. These polynomials are too complex for SAGE to solve, so we can input the system into something like [Magma](http://magma.maths.usyd.edu.au/calc/). The full solve script can be found in [`solve.sage`](https://github.com/0xmmalik/ritsec-ctf-2025/blob/main/cuwves%20%3C3/solve.sage).

#### Flag.
Combining the pieces of the flag we've extracted, we get the flag. `RITSEC{hey_im_just_w4ffl1n9_s0m3th1ng_rand0m_rn_th1s_is_cr4zy_it5_r3411y_n1ce_4nd_sunny_outs1d3_ev3n_th0ugh_its_f411_wh1ch_f33ls_w3ird_t0_me_lik3_i_th1nk_it_sh0uld_be_at_l345t_4_l1ttl3_b1t_c0ld3r_ugh}`

<small>(Some code for this writeup is partially adapted from [here](https://github.com/rkm0959/Inequality_Solving_with_CVP/).)</small>