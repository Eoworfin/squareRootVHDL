#==================================================================================
#  File:         <createreference.py>  -  <square root>
#  Author(s):    <Thomet / Group 10>
#  Created on:   <09.03.2026>
#  Project:      <square root>
# ==================================================================================

# generate_squareroot_golden.py
# Erstellt das Golden Reference File direkt im Ordner testbench/

# Golden Reference für squareRoot Entity
# Speicherort: goldne reference/golden_reference_square_root.txt
# Format: value roundup expected_result
# value   : 0 .. 1023 (Dezimal)
# roundup : 0 = floor (abrunden)
#         : 1 = round to nearest (half up)
# expected_result : korrekter 10-Bit Ergebniswert

import os
import math

def main():
    BIT_WIDTH = 10
    MAX_VAL = (1 << BIT_WIDTH) - 1   # 0 bis 1023
    
    # Speicherort
    directory = "golden reference"
    filename_value = os.path.join(directory, "golden_reference_squareroot_value.txt")
    filename_round = os.path.join(directory, "golden_reference_squareroot_round.txt")
    filename_result = os.path.join(directory, "golden_reference_squareroot_result.txt")
    
    
    print(f"Golden References wird erstellt unter:")
    print(f"   → {filename_value}")
    print(f"   → {filename_round}")
    print(f"   → {filename_result}")
    print(f"Anzahl Testcases: 2048 (alle 10-Bit Werte × roundup 0/1)\n")

    with open(filename_value, "w", encoding="utf-8") as f1:
        with open(filename_round, "w", encoding="utf-8") as f2:
            with open(filename_result, "w", encoding="utf-8") as f3:
                count = 0
                for value in range(MAX_VAL + 1):
                    for roundup in [0, 1]:
                        sqrt_real = math.sqrt(value)
                        
                        if roundup == 0:
                            result = math.floor(sqrt_real)      # abrunden
                        else:
                            result = round(sqrt_real)           # runden
                        
                        result = min(result, MAX_VAL)
                        
                        f1.write(f"{value}\n")
                        f2.write(f"{roundup}\n")       
                        f3.write(f"{result}\n")           
                        count += 1
                        if count % 512 == 0:
                            print(f"Fortschritt: {count}/2048 Testcases geschrieben...")

    print(f"\nFertig!")


if __name__ == "__main__":
    main()