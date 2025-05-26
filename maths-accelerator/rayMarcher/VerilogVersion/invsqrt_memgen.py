import math

## An inverse square root LUT memory generator that maps a 12-bit value (S) into 1/sqrt(S) Q1.15

# Configuration
INPUT_BITS = 12
INPUT_MAX   = 2**INPUT_BITS      
FRAC_BITS   = 15                     # Q1.15 format
OUTPUT_BITS = 16
MAX_OUT     = (1 << OUTPUT_BITS) - 1

with open('lut_init.mem', 'w') as f:
    for s in range(INPUT_MAX):
        if s == 0:
            out_val = 0
        else:
            inv_sqrt = 1.0 / math.sqrt(s)
            #Convert real number into Q1.15 by multiply by 2^15
            scaled   = int(round(inv_sqrt * (1 << FRAC_BITS)))
            out_val  = scaled
        # Write as 4‑digit hexadecimal (uppercase), one per line
        f.write(f"{out_val:04X}\n")

print(f"Generated {INPUT_MAX}‑entry inverse‑sqrt LUT in 'lut_init.mem'")
