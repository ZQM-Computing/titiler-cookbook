"""Generate a small synthetic float COG for pattern 02-rescaling.

Requires rasterio (version to confirm at validation).
The COG itself is generated at run time by this script — no binary COG
is shipped with this pattern.

Synthetic data only: a 64x64 float32 raster with values roughly in
1000–3000 (a range that does not map directly onto an 8-bit display
range, which is exactly why rescaling is needed). No real-world
measurements, no personal data, no real addresses.
"""

from pathlib import Path

import numpy as np
import rasterio
from rasterio.transform import from_origin

OUT = Path(__file__).parent / "synthetic_float.tif"
WIDTH, HEIGHT = 64, 64

xx, yy = np.meshgrid(np.arange(WIDTH), np.arange(HEIGHT))
checker = ((xx // 8) + (yy // 8)) % 2
values = (1000.0 + (xx / WIDTH) * 1500.0 + checker * 500.0).astype("float32")

profile = {
    "driver": "GTiff",
    "width": WIDTH,
    "height": HEIGHT,
    "count": 1,
    "dtype": "float32",
    "crs": "EPSG:3857",
    "transform": from_origin(0, 65536, 1024, 1024),
    "tiled": True,
    "blockxsize": 64,
    "blockysize": 64,
    "compress": "deflate",
}
with rasterio.open(OUT, "w", **profile) as dst:
    dst.write(values, 1)
    dst.build_overviews([2, 4], rasterio.enums.Resampling.average)

print(f"Wrote {OUT} ({WIDTH}x{HEIGHT}, float32, synthetic range ~1000-3000)")
