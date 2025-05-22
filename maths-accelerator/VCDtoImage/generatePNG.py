from vcdvcd import VCDVCD
from PIL import Image

# --- CONFIGURATION ---
vcd_file = "build/rgb_pattern.vcd"  # Make sure this matches your Verilog dumpfile
signal_name = "rgb_pattern_tb.dut.pixel_rgb[23:0]"  # Adjust if different
width, height = 640, 480
output_image = "rgb_output.png"

# --- LOAD VCD FILE ---
print("Parsing VCD file...")
vcd = VCDVCD(vcd_file, signals=[signal_name], store_tvs=True)

# --- CONVERSION FUNCTION ---
def binstr_to_rgb(b):
    val = int(b, 2)
    r = (val >> 16) & 0xFF
    g = (val >> 8) & 0xFF
    b = val & 0xFF
    return (r, g, b)

# --- EXTRACT SIGNAL VALUES ---
try:
    tv = vcd[signal_name].tv
except KeyError:
    print(f"ERROR: Signal '{signal_name}' not found in VCD.")
    print("Available signals:\n", "\n".join(vcd.signals))
    exit(1)

# --- FILTER & CONVERT PIXELS ---
pixels = []
for _, value in tv:
    if 'x' in value or 'z' in value:
        continue  # skip undefined or high-impedance values
    try:
        pixels.append(binstr_to_rgb(value))
    except ValueError:
        continue

# --- FIT TO IMAGE SIZE ---
expected_pixels = width * height
pixels = pixels[:expected_pixels]  # Truncate if too long
pixels += [(0, 0, 0)] * (expected_pixels - len(pixels))  # Pad if too short

# --- CREATE AND SAVE IMAGE ---
img = Image.new("RGB", (width, height))
img.putdata(pixels)
img.save(output_image)
print(f" Image saved to: {output_image}")