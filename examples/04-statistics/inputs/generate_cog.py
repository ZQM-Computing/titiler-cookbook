"""Generate a small synthetic multi-band COG for pattern 04-statistics.

Requires rasterio (version to confirm at validation).
The COG itself is generated at run time by this script — no binary COG
is shipped with this pattern.

Synthetic data only: a 64x64 two-band raster. Band 1 is a left-to-right
gradient (so a left-half window and a right-half window have clearly
different statistics); band 2 is a top-to-bottom gradient. No real-world
measurements, no personal data, no real addresses.
"""

from pathlib import Path

import numpy as np
import rasterio
from rasterio.transform import from_origin

OUT = Path(__file__).parent / "synthetic_multiband.tif"
WIDTH, HEIGHT = 64, 64

xx, yy = np.meshgrid(np.arange(WIDTH), np.arange(HEIGHT))
band1 = ((xx / WIDTH) * 255).astype("uint8")
band2 = ((yy / HEIGHT) * 255).astype("uint8")

profile = {
    "driver": "GTiff",
    "width": WIDTH,
    "height": HEIGHT,
    "count": 2,
    "dtype": "uint8",
    "crs": "EPSG:3857",
    "transform": from_origin(0, 65536, 1024, 1024),
    "tiled": True,
    "blockxsize": 64,
    "blockysize": 64,
    "compress": "deflate",
}
with rasterio.open(OUT, "w", **profile) as dst:
    dst.write(band1, 1)
    dst.write(band2, 2)
    dst.build_overviews([2, 4], rasterio.enums.Resampling.average)

print(f"Wrote {OUT} ({WIDTH}x{HEIGHT}, 2 bands, synthetic)")
