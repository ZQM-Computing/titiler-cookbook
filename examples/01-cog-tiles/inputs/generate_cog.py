"""Generate a small synthetic COG for pattern 01-cog-tiles.

Requires rasterio (version to confirm at validation).
The COG itself is generated at run time by this script — no binary COG
is shipped with this pattern.

Synthetic data only: a 64x64 single-band raster whose values are a
simple gradient plus a checkerboard, with no real-world measurements,
no personal data, and no real addresses.
"""

from pathlib import Path

import numpy as np
import rasterio
from rasterio.transform import from_origin

OUT = Path(__file__).parent / "synthetic.tif"
WIDTH, HEIGHT = 64, 64

# Synthetic values: gradient along x plus a checkerboard, scaled to 0-255.
xx, yy = np.meshgrid(np.arange(WIDTH), np.arange(HEIGHT))
checker = ((xx // 8) + (yy // 8)) % 2
values = ((xx / WIDTH) * 128 + checker * 64).astype("uint8")

profile = {
    "driver": "GTiff",
    "width": WIDTH,
    "height": HEIGHT,
    "count": 1,
    "dtype": "uint8",
    "crs": "EPSG:3857",
    # Arbitrary synthetic origin/extent; not a real place.
    "transform": from_origin(0, 65536, 1024, 1024),
    "tiled": True,
    "blockxsize": 64,
    "blockysize": 64,
    "compress": "deflate",
}
with rasterio.open(OUT, "w", **profile) as dst:
    dst.write(values, 1)
    # Build overviews so the file is cloud-optimized in shape.
    dst.build_overviews([2, 4], rasterio.enums.Resampling.average)
    dst.update_tags(ns="rio_overview", resampling="average")

print(f"Wrote {OUT} ({WIDTH}x{HEIGHT}, synthetic)")
