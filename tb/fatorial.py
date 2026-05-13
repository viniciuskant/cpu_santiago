# Imprime os números de 1 a 127 decompostos em fatores primos

def fatores_primos(n):
    fatores = []
    divisor = 2

    while n > 1:
        while n % divisor == 0:
            fatores.append(divisor)
            n //= divisor
        divisor += 1

    return fatores


for numero in range(1, 128):
    if numero == 1:
        print("1 = 1")
    else:
        fatores = fatores_primos(numero)
        print(f"{numero} =", " ".join(map(str, fatores)))