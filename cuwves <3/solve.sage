from sage.modules.free_module_integer import IntegerLattice


def Babai_CVP(mat, target):
    M = IntegerLattice(mat, lll_reduce=True).reduced_basis
    G = M.gram_schmidt()[0]
    diff = target
    for i in reversed(range(G.nrows())):
        diff -= M[i] * ((diff * G[i]) / (G[i] * G[i])).round()
    return target - diff


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


p = 17216570189694800463910705256589709556098544199557118122584770957513536769680657330070489864431723793890082855088816237801416471002721833394911369948564563

PR = PolynomialRing(GF(p), 2, ["x", "y"])
x, y = PR.gens()

C1 = (
    x ^ 2 + 11215316697629000704493183195977164861852195927403010777149812830692942539750742303560797292519644073379634556862777959482211250411478046727380670411743625 * x + 8073600359564908955921964367525142441921616356700369312210650019685913394607546301768691413478198043745283188436086920384747017520844274943472816351404303,
    y + 4472621942174702501044109572842111046517476371662128476026438933998108449861529876360465036941757604181116226854114865768883450361100221363399903229950226 * x + 6343561495002090281295484316012846523809817202714285519136305883969880132839003735052683810839474850010446188163447289138514709501205410182676799774441578)
C2 = (
    x ^ 3 + 381905754928224755575436197453306267834840039145691110469876275169508246685831106152355882638030080758270561398812015920682129611965428526916644439426052 * x ^ 2 + 11638799753754317590736477435714805513357226560644128069976619549749461167845891602727680134681453877102228946815335922435706646421096197665005614285498835 * x + 12214695887718715494441638810608507250623247365535027302205903712280741029774676731699824757311583593254975958296597412987521547978203550987269901477089547,
    y + 1928301333919256269461716181349250782317696750176401082376943574991437079187120574153773721916994605742626312156316388825695045193208928816254633612791919 * x ^ 2 + 12296526688217019524802112118238716737003197071638501848566236401645176922380291302525493751113925157016174928494753154625575330225015358542815893835746171 * x + 294856718024649256745670676849417055156909576487270616335508433991462169233225649260172303695204658057227077257469873256492932780673780773261592340848251)
C3 = (
    x + 12795775097566290830791524297570552333858566861521632899068855419137423580888786061735247095448452970812269447320737281114654933941269135753324751393302322,
    y + 7597235860561107976460153421520202657580734319928723809549567925690039059654966803132807917057053958118084576817237095249233512808198732598995402073933741)

two_J1_P1_two_J1_P2 = C1
five_J2_P3 = C2
J2_P4 = C3

U1, V1 = two_J1_P1_two_J1_P2[0], -two_J1_P1_two_J1_P2[1].subs({x: x, y: 0})
U2, V2 = five_J2_P3[0], -five_J2_P3[1].subs({x: x, y: 0})
U3, V3 = J2_P4[0], -J2_P4[1].subs({x: x, y: 0})

hint = GF(p)(int.from_bytes(b"These are some of my recent thoughts. You are required to agree!", "big"))

assert J2_P4[0].subs({x: hint, y: y}) == GF(p)(0)

g1, g2 = 2, 3

hc_def_pol_coef_rng = PolynomialRing(GF(p), 2 * g2 + 2, ["c%d" % i for i in range(2 * g2 + 2)])
ci = hc_def_pol_coef_rng.gens()

hc_def_pol_rng = PolynomialRing(hc_def_pol_coef_rng, "X")
X = hc_def_pol_rng.gens()[0]

f1symbpol = sum(ci[i] * (X ** i) for i in range(2 * g1 + 2))
f2symbpol = sum(ci[i] * (X ** i) for i in range(2 * g2 + 2))

mumford_rel_1 = (f1symbpol - V1.subs({x: X, y: 0}) ^ 2).quo_rem(U1.subs({x: X, y: 0}))[1].list()  # g1-equations
mumford_rel_2 = (f2symbpol - V2.subs({x: X, y: 0}) ^ 2).quo_rem(U2.subs({x: X, y: 0}))[1].list()  # g2-equations
mumford_rel_3 = (f2symbpol - V3.subs({x: X, y: 0}) ^ 2).quo_rem(U3.subs({x: X, y: 0}))[1].list()  # 1-equations

mumford_rel = mumford_rel_1 + mumford_rel_2 + mumford_rel_3

coef, _ = Sequence(mumford_rel).coefficient_matrix()

mat = [([int(coef[i][j].lift()) for j in range(2 * g2 + 3)] + [0] * i + [p] + [0] * (coef.nrows() - i - 1)) for i in
       range(coef.nrows())]
mat += [[0] * i + [1] + [0] * (2 * g2 + 1 - i) + [0] + [0] * coef.nrows() for i in range(2 * g2 + 2)]
mat.append([0] * (2 * g2 + 2) + [1] + [0] * coef.nrows())

mat = matrix(ZZ, mat).transpose()
lb, ub = [0] * coef.nrows() + [0] * (2 * g2 + 2) + [1], [0] * coef.nrows() + [2 ** (8 * 42)] * (2 * g2 + 2) + [1]

sols = solve(mat, lb, ub)
sol = sols[2]

f1 = sum(GF(p)(sol[i]) * (X ** i) for i in range(2 * g1 + 2))
f2 = sum(GF(p)(sol[i]) * (X ** i) for i in range(2 * g2 + 2))

assert (f1 - V1.subs({x: X}) ^ 2) % U1.subs({x: X}) == 0
assert (f2 - V2.subs({x: X}) ^ 2) % U2.subs({x: X}) == 0
assert (f2 - V3.subs({x: X}) ^ 2) % U3.subs({x: X}) == 0

polsymbrng_flag3 = PolynomialRing(GF(p), 3, ["A", "B", "a"])
A, B, a = polsymbrng_flag3.gens()
hc_def_pol_flag3 = PolynomialRing(polsymbrng_flag3, "X")
X_flag3 = hc_def_pol_flag3.gens()[0]

v_bar_flag3 = -V2.subs({x: X_flag3}) + (A + B * X_flag3) * U2.subs({x: X_flag3})
f2symbpol_flag3 = sum([GF(p)(ele) * X_flag3 ^ i for i, ele in enumerate(f2.list())])

lefthand = f2symbpol_flag3 - v_bar_flag3 ^ 2
righthand = -B ^ 2 * (X_flag3 - a) ^ 5 * U2.subs({x: X_flag3})
equ = [(lefthand.list()[i] - righthand.list()[i]) for i in range(len(lefthand.list()))]

I_flag3 = polsymbrng_flag3.ideal(equ)
V_flag3 = I_flag3.variety()
flag3_root = V_flag3[0][a]
flag3 = int.to_bytes(int(flag3_root.lift()), 64, 'big')

polsymbrng_flag12 = PolynomialRing(GF(p), 4, ["A", "B", "a", "b"])
A, B, a, b = polsymbrng_flag12.gens()
hc_def_pol_flag12 = PolynomialRing(polsymbrng_flag12, "X")
X_flag12 = hc_def_pol_flag12.gens()[0]

v_bar_flag12 = -V1.subs({x: X_flag12}) + (A + B * X_flag12) * U1.subs({x: X_flag12})
f1symbpol_flag12 = sum([GF(p)(ele) * X_flag12 ^ i for i, ele in enumerate(f1.list())])
lefthand = f1symbpol_flag12 - v_bar_flag12 ^ 2
righthand = -B ^ 2 * (X_flag12 ^ 2 - a * X_flag12 + b) ^ 2 * U1.subs({x: X_flag12})
lefthand_list = lefthand.list()
righthand_list = righthand.list()

assert len(lefthand_list) == (1 + 2) * 2 + 1
assert len(righthand_list) == 2 * 2 + 2 + 1

equ = []
for i in range(len(lefthand_list)):
    equele = lefthand_list[i] - righthand_list[i]
    equ.append(equele)

I_flag12 = polsymbrng_flag12.ideal(equ)
print("computing flag12")
G_flag12 = I_flag12.groebner_basis()

# put the contents of magmaout.txt in Magma to solve system, then put output into "sol"
magmaout = open('magmaout.txt', 'w')
magmaout.write(f"p:={p};\n")
magmaout.write(f"P<A, B, a, b>:=PolynomialRing(GF(p), 4);\n")
magmaout.write(f"I := ideal<P |\n")
magmaout.write(f"{str(G_flag12[:5])[1:-1]}>;\n")
magmaout.write(f"Variety(I);\n")

sol = [(
    16659260478274173759492459629614710652608011102204749298728877245125326588131477039150651747833159845217908602355840240060484242085986910527251968914263779,
    6696411814380000861077570247525930549244949817527188416911649279470055948157015629410849744393308537418961383607311476158950387403502706878235914949085449,
    11824490283124583208484082215260266437095457082533612887483876810391034398541395104976389226587176401656083109102264169184708635953606021903797712220231056,
    1436094812183885506729672294583680044048055268834114892935822459432983814060843594066515248834762445851215652033224609779880769206515026031254627989697922)]

flag12_add_root = GF(p)(sol[0][2])
flag12_mul_root = GF(p)(sol[0][3])

flag12_pol = PolynomialRing(GF(p), "flag12")
flag12 = flag12_pol.gens()[0]
flag12_roots = (flag12 ^ 2 - flag12_add_root * flag12 + flag12_mul_root).roots()
print(flag12_roots)

flag1 = int.to_bytes(int(flag12_roots[0][0].lift()), 64, 'big')
print(flag1)
flag2 = int.to_bytes(int(flag12_roots[1][0].lift()), 64, 'big')
print(flag2)
print(f"\n\nRS{{{str(flag2)[2:-1]}{str(flag1)[2:-1]}{str(flag3)[2:-1]}}}")
