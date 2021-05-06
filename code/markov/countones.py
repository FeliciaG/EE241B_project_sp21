import math
with open('trng_out770.txt') as f:
       num = f.readlines()
       lst = [int(n) for n in num]
print(sum(lst), len(lst))
