# 03 — STAC Endpoints: Tiles and Statistics Against a pgSTAC Catalog

## What it demonstrates

Using TiTiler's STAC-backed endpoints to serve tiles and statistics for an
item held in a pgSTAC catalog, instead of pointing TiTiler at a bare file
URL. The pattern shows the catalog-first path: look the item up in the
catalog, then pass the catalog's item reference to TiTiler's `/stac/*`
endpoints for bounds, info, tiles, and statistics. No live catalog is
shipped or assumed here; every catalog interaction is a documented API
call with placeholders.

## Prerequisites + versions

- Python 3.11+
- TiTiler 0.25.0 (Python venv; app entry `titiler.application.main:app`)
- pgSTAC 0.10.0 and stac-fastapi.pgstac 7.1.0 (fleet versions per the
  seed; catalog port and base URL: to confirm at validation — use
  `<STAC_API_URL>` only, never a stated port)
- A running TiTiler instance, addressed only as `<TITILER_URL>`
  (TiTiler port: to confirm at validation)
- `curl` for the example script
- Verified per the seed: `/healthz` and `/redoc` on Node-1 and Node-3 for
  TiTiler 0.25.0. Anything else about the deployment is to confirm at
  validation.

## Steps

1. Confirm the catalog is reachable (placeholder only — no credentials):

   ```bash
   curl "<STAC_API_URL>/collections"
   ```

   The exact collections path and response shape are to confirm at
   validation against the deployed stac-fastapi.pgstac 7.1.0 API.
2. Pick a collection and item. In `example.sh`, set `<STAC_API_URL>`,
   `<TITILER_URL>`, `<COLLECTION_ID>`, and `<ITEM_ID>`. A synthetic
   example item document is in `inputs/example-item.json` for shape
   reference only; it is not a live catalog record.
3. Run the script:

   ```bash
   bash example.sh
   ```

   It calls the catalog item endpoint, then TiTiler's `/stac/bounds`,
   `/stac/info`, `/stac/tilejson.json`, one `/stac/tiles/{z}/{x}/{y}.png`
   tile, and `/stac/statistics` for that item.
4. Compare the `/stac/statistics` output with the item's own band
   metadata to confirm the statistics came from the catalog item's
   assets, not from an unrelated file.

## Expected output

- The catalog item lookup returns the item document (with assets) for
  `<COLLECTION_ID>` / `<ITEM_ID>`.
- `/stac/bounds` returns the item's bounding box.
- `/stac/info` returns band information for the item's raster asset.
- `/stac/tilejson.json` returns a TileJSON document for the item.
- One in-bounds `/stac/tiles/{z}/{x}/{y}.png` tile returns HTTP 200 PNG.
- `/stac/statistics` returns band statistics for the item.

Exact endpoint spellings, parameter names, and response bodies are to
confirm at validation against TiTiler 0.25.0 and stac-fastapi.pgstac
7.1.0; the sequence above is the design expectation, not a recorded run.

## Failure behavior

- Invalid input: an unknown `<COLLECTION_ID>` or `<ITEM_ID>`, or an item
  with no raster asset, is expected to produce an error response from
  the catalog and/or the `/stac/*` endpoints (HTTP 4xx) and no tile,
  rather than a tile from a different item.
- No-result case: a tile coordinate outside the item's bounds, or a
  statistics request over a window with no data, is expected to return
  an error or an empty result per TiTiler's configured behavior — never
  statistics or tiles from another item. Exact status codes are to
  confirm at validation.
- An unreachable catalog or TiTiler instance fails loudly in `curl`
  (connection error), not as a false success.

## Evidence

Evidence: design-only, gate 1 target.

This pattern has not been run and is not runtime-validated. No live
catalog, run log, screenshot, or live response is claimed.

## Gate-3 proof

What would prove runtime validation: run `bash example.sh` against
TiTiler 0.25.0 (Python venv, app entry `titiler.application.main:app`)
on Node-1 or Node-3 — the nodes where `/healthz` and `/redoc` were
verified per the seed — with `<STAC_API_URL>` pointed at a pgSTAC
0.10.0 / stac-fastapi.pgstac 7.1.0 catalog holding a known synthetic
item, and record the item lookup, `/stac/bounds`, `/stac/info`, one
in-bounds tile, and `/stac/statistics` responses (status codes and
key fields). The catalog port and the exact STAC endpoint spellings
would be confirmed by that run. The stack is not claimed to be deployed
end-to-end beyond what this run would show.
