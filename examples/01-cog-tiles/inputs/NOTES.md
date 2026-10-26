# inputs/ — 01-cog-tiles

- `generate_cog.py` requires rasterio (version to confirm at validation).
- The COG itself is generated at run time by running that script; it is
  not shipped as a binary file with this pattern, and no binary COG was
  fabricated by hand.
- Output: `inputs/synthetic.tif` (64x64, single band, synthetic values only).
