n = 63
a = 1
for i in range(1, 6):
    b = n / a
    print(f"Iteração {i}:")
    print(f"a = {int(a)}")
    print(f"b = {int(b)}")

    # nova aproximação
    a = (a + b) / 2
    print(f"novo a = {int(a)}")
    print("-" * 30)