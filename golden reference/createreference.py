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
    filename = os.path.join(directory, "golden_reference_squareroot.txt")
    
    # Erstelle Ordner "testbench", falls noch nicht existiert
    os.makedirs(directory, exist_ok=True)
    
    print(f"Golden Reference wird erstellt unter:")
    print(f"   → {filename}")
    print(f"Anzahl Testcases: 2048 (alle 10-Bit Werte × roundup 0/1)\n")
    
    with open(filename, "w", encoding="utf-8") as f:
       
        count = 0
        for value in range(MAX_VAL + 1):
            for roundup in [0, 1]:
                sqrt_real = math.sqrt(value)
                
                if roundup == 0:
                    result = math.floor(sqrt_real)      # abrunden
                else:
                    result = round(sqrt_real)           # runden
                
                result = min(result, MAX_VAL)
                
                f.write(f"{value} {roundup} {result}\n")
                
                count += 1
                if count % 512 == 0:
                    print(f"Fortschritt: {count}/2048 Testcases geschrieben...")
    
    file_size_kb = os.path.getsize(filename) / 1024
    print(f"\nFertig!")
    print(f"Datei erfolgreich erstellt: {filename}")
    print(f"Dateigröße: {file_size_kb:.1f} KB")

if __name__ == "__main__":
    main()