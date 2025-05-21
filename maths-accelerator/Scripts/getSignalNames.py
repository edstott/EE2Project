from vcdvcd import VCDVCD

vcd = VCDVCD("build/rgb_pattern.vcd", store_tvs=True)

print("Available signals:")
for signal in vcd.signals:
    print(signal)