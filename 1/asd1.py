







with open("input") as f:

    calibration_sum = 0

    lines = f.readlines()
    for line in lines:
        
        first  = "nan"
        second = "nan"
        for c in line:
            if ord('0') <= ord(c) and ord(c) <= ord('9'):
                if first == "nan":
                    first = c
                    second = first
                else:
                    second = c
        num = int(first+second)
        calibration_sum += num
        print(f"{first} {second} {num}")

    print(f"calibration sum = {calibration_sum}")
