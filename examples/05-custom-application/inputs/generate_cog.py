"""Generate a small synthetic COG for pattern 05-custom-application.

Requires rasterio (version to confirm at validation).
The COG itself is generated at run time by this script — no binary COG
is shipped with this pattern.

Synthetic data only: a 64x64 single-band raster with a simple gradient.
No real-world measurements, no personal data, no real addresses.
"""

from pathlib import Path

import numpy as np
import rasterio
from rasterio.transform import from_origin

OUT = Path(__file__).parent / "synthetic.tif"
WIDTH, HEIGHT = 64, 64

xx, _yy = np.meshgrid(np.arange(WIDTH), np.arange(HEIGHT))
values = ((xx / WIDTH) * 255).astype("uint8")

profile = {
    "driver": "GTiff",
    "width": WIDTH,
    "height": HEIGHT,
    "count": 1,
    "dtype": "uint8",
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

print(f"Wrote {OUT} ({WIDTH}x{HEIGHT}, synthetic)")
