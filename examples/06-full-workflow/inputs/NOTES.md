# inputs/ — 06-full-workflow

- `generate_cog.py` requires rasterio (version to confirm at validation).
- The COG itself is generated at run time by running that script; it is
  not shipped as a binary file with this pattern, and no binary COG was
  fabricated by hand.
- Output: `inputs/synthetic.tif` (64x64, single band, synthetic values only).
- `register-item-template.json` is a SYNTHETIC catalog registration
  payload template with placeholders (`<COG_URL>`, `<COLLECTION_ID>`,
  `<ITEM_ID>`). Its bbox/geometry must be replaced with the generated
  COG's real bounds at validation, and its POST path/fields confirmed
  against stac-fastapi.pgstac 7.1.0. It is not a live catalog record.
- The pgSTAC catalog interaction is via documented API calls with
  placeholders (see `example.sh`), not a live catalog. No credentials
  are included anywhere in this pattern.
