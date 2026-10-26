# 04 — Statistics: Band Statistics and Histograms Without Reading the Whole Raster

## What it demonstrates

Computing band statistics and histograms over a window of a raster through
TiTiler, without reading the whole raster. The pattern shows three
scopes — full raster, a bounding-box window, and a single band — and
shows that a windowed request returns statistics for that window only.
The point is efficiency and precision: TiTiler reads the COG's internal
tiles/overviews for the requested window rather than downloading and
scanning the entire file.

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

1. Generate the synthetic multi-band COG (created at run time, not shipped):

   ```bash
   python inputs/generate_cog.py
   ```

   This writes `inputs/synthetic_multiband.tif` (64x64, 2 bands,
   synthetic values only).
2. Set `<TITILER_URL>` and `<COG_URL>` at the top of `example.sh`, plus
   `<BBOX>` (a window inside the COG's bounds, from `/cog/bounds`).
3. Run the script:

   ```bash
   bash example.sh
   ```

   It requests full-raster statistics, windowed statistics for
   `<BBOX>`, single-band statistics (`bidx=1`), and a histogram, in
   that order.
4. Compare full vs. windowed statistics: the windowed min/max must
   differ from (or be a subset of) the full-raster values in a way
   consistent with the synthetic gradient, confirming the window was
   honored.

## Expected output

- Full-raster `/cog/statistics` returns per-band statistics (min, max,
  mean, and related fields) for both synthetic bands.
- Windowed `/cog/statistics` with `bbox=<BBOX>` returns statistics
  computed over that window only.
- Single-band statistics (`bidx=1`) return statistics for band 1 only,
  with no band-2 fields.
- `/cog/histogram` returns bin counts for the requested band(s).

Exact field names, parameter spellings, and response bodies are to
confirm at validation against TiTiler 0.25.0; the scopes above are the
design expectation, not a recorded run.

## Failure behavior

- Invalid input: a malformed `bbox` (wrong number of values, non-numeric
  values, or min >= max on an axis), an out-of-range `bidx`, or a
  malformed histogram parameter is expected to produce an error
  response (HTTP 4xx) and no statistics, rather than silently
  substituting a different window or band.
- No-result case: a `bbox` that does not intersect the raster at all, or
  a window covering only nodata, is expected to return an error or an
  empty statistics result — never statistics from the full raster
  presented as windowed statistics. The exact status code and body are
  to confirm at validation.
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
full, windowed, and single-band statistics plus the histogram (status
codes and key fields), with a check that the windowed values differ
from the full-raster values as the synthetic gradient predicts. The
stack is not claimed to be deployed end-to-end beyond what this run
would show.
