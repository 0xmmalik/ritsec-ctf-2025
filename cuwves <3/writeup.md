# RITSEC CTF 2025 Writeup
## cuwves <3

The first thing we need to do is recover the value of the prime `p`. We can do this pretty easily given the fact that we have the bytes used to create the third curve, `b'These are some of my recent thoughts. You are required to agree!'`. Now, we can factor to determine `p`:

```python
x, y = var('x y')

C3 = (x + 12795775097566290830791524297570552333858566861521632899068855419137423580888786061735247095448452970812269447320737281114654933941269135753324751393302322, y + 7597235860561107976460153421520202657580734319928723809549567925690039059654966803132807917057053958118084576817237095249233512808198732598995402073933741)
txt = int.from_bytes(b"These are some of my recent thoughts. You are required to agree!", "big")

print(factor(C3[0](x=txt)))
```