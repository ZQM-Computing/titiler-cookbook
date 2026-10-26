# 06 — Full Workflow: COG → Catalog → Tiles → Statistics

## What it demonstrates

The end-to-end workflow that ties the earlier patterns together: generate
a COG, register it as an item in a pgSTAC catalog, then serve tiles and
statistics for it through TiTiler's STAC endpoints. Each stage hands off
to the next by reference (file URL → catalog item → STAC endpoints), so
no stage re-uploads or re-reads the raster by hand. The catalog step is
shown as documented API calls with placeholders, not a live catalog.

## Prerequisites + versions

- Python 3.11+
- TiTiler 0.25.0 (Python venv; app entry `titiler.application.main:app`)
- pgSTAC 0.10.0 and stac-fastapi.pgstac 7.1.0 (fleet versions per the
  seed; catalog port and base URL: to confirm at validation — use
  `<STAC_API_URL>` only, never a stated port)
- A running TiTiler instance, addressed only as `<TITILER_URL>`
  (TiTiler port: to confirm at validation)
- `curl` for the example script, `jq` recommended for inspecting JSON
  responses (jq version: to confirm at validation)
- `rasterio` for the synthetic-COG generator in `inputs/` (rasterio version:
  to confirm at validation)
- Verified per the seed: `/healthz` and `/redoc` on Node-1 and Node-3 for
  TiTiler 0.25.0. Anything else about the deployment is to confirm at
  validation.

## Steps

1. Generate the synthetic COG (created at run time, not shipped):

   ```bash
   python inputs/generate_cog.py
   ```

   This writes `inputs/synthetic.tif` (64x64, synthetic values only).
2. Publish the COG at a URL TiTiler and the catalog can both reach, and
   set `<COG_URL>` in `example.sh` (publishing method and hosting:
   to confirm at validation).
3. Set the remaining placeholders in `example.sh`: `<TITILER_URL>`,
   `<STAC_API_URL>`, `<COLLECTION_ID>`, `<ITEM_ID>`.
4. Run the script:

   ```bash
   bash example.sh
   ```

   In order it: checks TiTiler health; registers the item in the
   catalog (POST, placeholder payload in `inputs/register-item-template.json`);
   reads the item back; requests `/stac/bounds`, `/stac/info`,
   `/stac/tilejson.json`, one `/stac/tiles/{z}/{x}/{y}.png` tile, and
   `/stac/statistics`; and finally requests `/cog/statistics` directly
   against `<COG_URL>` as a cross-check.
5. Compare the STAC statistics with the direct-COG statistics: for the
   same band, they must agree (within rounding), confirming the catalog
   item points at the intended COG and not at a different asset.

## Expected output

- The catalog POST returns a created/accepted response for
  `<COLLECTION_ID>` / `<ITEM_ID>` (exact status code: to confirm at
  validation against stac-fastapi.pgstac 7.1.0).
- Reading the item back returns the registered document with the COG
  asset href matching `<COG_URL>`.
- `/stac/bounds`, `/stac/info`, and `/stac/tilejson.json` all succeed
  for the registered item.
- One in-bounds `/stac/tiles/{z}/{x}/{y}.png` tile returns HTTP 200 PNG.
- `/stac/statistics` succeeds, and its band values agree with the
  direct `/cog/statistics` cross-check.

Exact endpoint spellings, payload fields, and response bodies are to
confirm at validation; the sequence above is the design expectation,
not a recorded run.

## Failure behavior

- Invalid input: a registration payload with a missing asset href, an
  unknown collection, or a duplicate item ID (if the catalog rejects
  duplicates) is expected to produce an error response from the catalog
  (HTTP 4xx) and the script stops before any tile request, rather than
  tiling a stale or wrong item.
- No-result case: if the catalog item exists but its asset URL is
  unreachable, the `/stac/*` endpoints are expected to error and return
  no tile/statistics, rather than falling back to another item. A tile
  coordinate outside the item's bounds is expected to error or return
  an empty tile, never another item's tile. Exact status codes are to
  confirm at validation.
- If any stage fails, later stages must not be read as proof of the
  failed stage: the script uses `set -euo pipefail` so a failed
  registration aborts before tiling.

## Evidence

Evidence: design-only, gate 1 target.

This pattern has not been run and is not runtime-validated. No live
catalog, run log, screenshot, or live response is claimed.

## Gate-3 proof

What would prove runtime validation: run `bash example.sh` end to end
against TiTiler 0.25.0 (Python venv, app entry
`titiler.application.main:app`) on Node-1 or Node-3 — the nodes where
`/healthz` and `/redoc` were verified per the seed — with
`<STAC_API_URL>` pointed at a pgSTAC 0.10.0 / stac-fastapi.pgstac
7.1.0 catalog, using `inputs/generate_cog.py`, and record the catalog
POST/read-back, `/stac/bounds`, `/stac/info`, one in-bounds tile,
`/stac/statistics`, and the direct `/cog/statistics` cross-check
(status codes and key fields, including the STAC-vs-direct agreement
check). The catalog port and exact STAC endpoint/payload spellings
would be confirmed by that run. The stack is not claimed to be deployed
end-to-end beyond what this run would show.
