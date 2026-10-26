# 01 — COG Tiles: Serving a Local COG as XYZ Tiles

## What it demonstrates

Serving a local Cloud-Optimized GeoTIFF (COG) as XYZ map tiles through TiTiler,
and inspecting that COG through the `/cog/info` endpoint before requesting any
tiles. The pattern shows the minimal read path: one raster file in, tile URLs
out, with no catalog, database, or tile cache in between.

## Prerequisites + versions

- Python 3.11+
- TiTiler 0.25.0 (Python venv; app entry `titiler.application.main:app`)
- A running TiTiler instance, addressed in this pattern only as `<TITILER_URL>`
  (TiTiler port: to confirm at validation — the seed states no TiTiler port,
  so no port is stated here as fact)
- `curl` for the example script
- `rasterio` for the synthetic-COG generator in `inputs/` (rasterio version:
  to confirm at validation)
- Verified per the seed: `/healthz` and `/redoc` on Node-1 and Node-3 for
  TiTiler 0.25.0. Anything else about the deployment is to confirm at
  validation.

## Steps

1. Generate the synthetic COG (it is created at run time, not shipped here):

   ```bash
   python inputs/generate_cog.py
   ```

   This writes `inputs/synthetic.tif` (64x64, synthetic values only).
2. Serve the COG over HTTP, or point TiTiler at a file URL it can read, and
   set the placeholders at the top of `example.sh`:
   `<TITILER_URL>` and `<COG_URL>`.
3. Check health, then inspect the COG:

   ```bash
   bash example.sh
   ```

   The script calls `/healthz`, `/cog/info`, `/cog/bounds`, and one
   `/cog/tiles/{z}/{x}/{y}.png` tile in order.
4. Open the returned `TileJSON` URL in a map client to confirm the tile
   template resolves (map client name and version: to confirm at validation).

## Expected output

- `/healthz` returns a healthy status.
- `/cog/info` returns band descriptions, data type, and bounds for the
  synthetic COG.
- `/cog/bounds` returns the COG's bounding box.
- `/cog/tiles/{z}/{x}/{y}.png` returns a PNG tile (HTTP 200) for a tile
  inside the COG's bounds at a zoom the COG supports.
- `/cog/tilejson.json` returns a TileJSON document whose `tiles` template
  contains the tile endpoint pattern.

Exact response bodies are to confirm at validation; the shapes above are
the design expectation, not a recorded run.

## Failure behavior

- Invalid input: a `<COG_URL>` that does not resolve, is not a readable
  raster, or is not a COG is expected to produce an error response from the
  `/cog/*` endpoints (HTTP 4xx/5xx depending on the failure) and no tile,
  rather than a blank or silently wrong tile.
- No-result case: a tile coordinate outside the COG's bounds, or a zoom
  outside the supported range, is expected to return an error or an empty
  tile response per TiTiler's configured behavior — never a tile from a
  different raster. The exact status code and body are to confirm at
  validation.
- A TiTiler instance that is not running produces connection failures from
  `curl`; the script prints the failing URL so the bad placeholder is
  visible instead of being masked.

## Evidence

Evidence: design-only, gate 1 target.

This pattern has not been run and is not runtime-validated. No run log,
screenshot, or live response is claimed.

## Gate-3 proof

What would prove runtime validation: run `bash example.sh` with
`<TITILER_URL>` pointed at TiTiler 0.25.0 (Python venv, app entry
`titiler.application.main:app`) on Node-1 or Node-3 — the nodes where
`/healthz` and `/redoc` were verified per the seed — using the
`inputs/generate_cog.py` synthetic COG, and record the `/cog/info`,
`/cog/bounds`, and one in-bounds tile response (status code, content type,
and tile dimensions). A matching `TileJSON` response completes the proof.
The stack is not claimed to be deployed end-to-end beyond what this run
would show.
