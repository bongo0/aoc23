





numbers = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine"
]

with open("input") as f:

    calibration_sum = 0

    lines = f.readlines()
    for line in lines:
        
        first  = "nan"
        second = "nan"
        for i in range(0,len(line)):
            c = line[i]
            if ord('0') <= ord(c) and ord(c) <= ord('9'):
                if first == "nan":
                    first = c
                    second = first
                else: second = c
            else:
                for j in range(0,10):
                    if line[i:].startswith(numbers[j]):
                        if first == "nan":
                            first = str(j)
                            second = first
                        else: second = str(j)

        num = int(first+second)
        calibration_sum += num
        print(f"{first} {second} {num}")

    print(f"calibration sum = {calibration_sum}")
