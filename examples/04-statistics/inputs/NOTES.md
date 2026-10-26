# inputs/ — 04-statistics

- `generate_cog.py` requires rasterio (version to confirm at validation).
- The COG itself is generated at run time by running that script; it is
  not shipped as a binary file with this pattern, and no binary COG was
  fabricated by hand.
- Output: `inputs/synthetic_multiband.tif` (64x64, 2 bands, synthetic
  values only: band 1 left-to-right gradient, band 2 top-to-bottom
  gradient).
