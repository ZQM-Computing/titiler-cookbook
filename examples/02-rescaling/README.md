# 02 — Rescaling: Making Float Rasters Render as Tiles

## What it demonstrates

Rescaling float rasters with TiTiler's `rescale` parameters so tiles render
instead of failing or rendering blank. A float raster whose native value
range does not map onto a displayable range (for example, values in the
thousands stored as float32) needs an explicit input range mapped to the
output range before a PNG tile can show anything useful. This pattern shows
the unscaled request, the rescaled request, and how to pick the range from
the raster's own statistics.

## Prerequisites + versions

- Python 3.11+
- TiTiler 0.25.0 (Python venv; app entry `titiler.application.main:app`)
- A running TiTiler instance, addressed only as `<TITILER_URL>`
  (TiTiler port: to confirm at validation)
- `curl` for the example script
- `rasterio` for the synthetic-COG generator in `inputs/` (rasterio version:
  to confirm at validation)
- Verified per the seed: `/healthz` and `/redoc` on Node-1 and Node-3 for
  TiTiler 0.25.0. Anything else about the deployment is to confirm at
  validation.

## Steps

1. Generate the synthetic float COG (created at run time, not shipped):

   ```bash
   python inputs/generate_cog.py
   ```

   This writes `inputs/synthetic_float.tif` (64x64, float32, synthetic
   values roughly in the range 1000–3000).
2. Set `<TITILER_URL>` and `<COG_URL>` at the top of `example.sh`.
3. Run the script:

   ```bash
   bash example.sh
   ```

   It requests `/cog/statistics` first (to read the real value range),
   then one tile without `rescale`, then the same tile with
   `rescale=<MIN>,<MAX>` taken from that range.
4. Compare the two tile files. The rescaled tile is the one expected to
   show the synthetic gradient; the unscaled tile is the control case.

## Expected output

- `/cog/statistics` returns a min/max (and related statistics) for the
  synthetic float band, within the generator's designed range.
- The unscaled tile request returns a tile that is blank, washed out, or
  otherwise not a useful rendering of the data (the exact appearance is to
  confirm at validation — it is the control, not the result).
- The rescaled tile request (`rescale=<MIN>,<MAX>`) returns a PNG tile
  (HTTP 200) in which the synthetic gradient/checkerboard is visible.
- Re-running with a narrower `rescale` range increases contrast; widening
  it decreases contrast. Exact pixel values are to confirm at validation.

## Failure behavior

- Invalid input: a malformed `rescale` value (for example, a non-numeric
  bound, a single bound where a pair is required, or min >= max) is
  expected to produce an error response (HTTP 4xx) and no tile, rather
  than a silently mis-scaled tile.
- No-result case: a tile coordinate outside the COG's bounds, or a
  `rescale` range that excludes all of the raster's values, is expected
  to return an error or a uniform/blank tile — never data from another
  raster. The exact status code and body are to confirm at validation.
- A missing `<COG_URL>` or unreachable TiTiler instance fails loudly in
  `curl` (connection error), not as a false success.

## Evidence

Evidence: design-only, gate 1 target.

This pattern has not been run and is not runtime-validated. No run log,
screenshot, or live response is claimed.

## Gate-3 proof

What would prove runtime validation: run `bash example.sh` against
TiTiler 0.25.0 (Python venv, app entry `titiler.application.main:app`)
on Node-1 or Node-3 — the nodes where `/healthz` and `/redoc` were
verified per the seed — using `inputs/generate_cog.py`, and record the
`/cog/statistics` min/max, the unscaled tile outcome, and the rescaled
tile outcome (status codes, content types, and a visual or pixel check
that the rescaled tile shows the synthetic pattern). The stack is not
claimed to be deployed end-to-end beyond what this run would show.
