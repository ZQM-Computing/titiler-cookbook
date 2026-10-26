# 05 — Custom Application: Extending TiTiler with a Custom Endpoint Factory

## What it demonstrates

Extending the TiTiler application with a custom endpoint factory: starting
from TiTiler's standard COG endpoints and adding one custom endpoint of
your own, in the same FastAPI application, without forking TiTiler. The
example adds a `/custom/ping` health-style endpoint and a
`/custom/band-summary` endpoint that wraps the standard COG statistics
call for a single band and returns a reduced summary. The point is the
extension mechanism — a factory/router mounted alongside the built-in
ones — not the two example endpoints themselves.

## Prerequisites + versions

- Python 3.11+
- TiTiler 0.25.0 (Python venv; app entry for the stock application is
  `titiler.application.main:app` — this pattern builds its own app in
  `app.py` instead of using the stock entry point)
- FastAPI and uvicorn (versions: to confirm at validation; they ship
  with the TiTiler application stack — confirm the pinned versions at
  validation rather than assuming them)
- `rasterio` for the synthetic-COG generator in `inputs/` (rasterio version:
  to confirm at validation)
- `curl` for probing the custom endpoints
- A URL for the custom app once running, addressed only as
  `<CUSTOM_APP_URL>` (port: to confirm at validation)
- Verified per the seed: `/healthz` and `/redoc` on Node-1 and Node-3 for
  stock TiTiler 0.25.0. Anything else about the deployment is to confirm
  at validation.

## Steps

1. Generate the synthetic COG (created at run time, not shipped):

   ```bash
   python inputs/generate_cog.py
   ```

   This writes `inputs/synthetic.tif` (64x64, synthetic values only).
2. Install TiTiler 0.25.0 into a Python 3.11+ venv (install command and
   package index: to confirm at validation) and set `<COG_URL>` in
   `app.py` (or pass it per request — see the code comments).
3. Run the custom application:

   ```bash
   uvicorn app:app --host <HOST> --port <PORT>
   ```

   Host and port are placeholders: to confirm at validation. Do not
   copy a port from another pattern; none is stated as fact here.
4. Probe the endpoints:

   ```bash
   curl "<CUSTOM_APP_URL>/custom/ping"
   curl "<CUSTOM_APP_URL>/cog/info?url=<COG_URL>"
   curl "<CUSTOM_APP_URL>/custom/band-summary?url=<COG_URL>&bidx=1"
   ```

   The first proves the custom router is mounted; the second proves the
   stock COG endpoints still work beside it; the third proves the custom
   endpoint itself.
5. Open `<CUSTOM_APP_URL>/docs` (or `/redoc`) to confirm both the stock
   and custom routes appear in the generated API docs (docs path:
   to confirm at validation).

## Expected output

- `/custom/ping` returns a small JSON success payload (exact body is
  defined in `app.py`).
- `/cog/info` returns the same band/bounds information as the stock
  TiTiler application for the synthetic COG.
- `/custom/band-summary` returns a reduced summary (band index, min, max,
  mean) for the requested band of the synthetic COG — once the
  statistics-delegation TODO in `app.py` is completed at validation
  (until then it raises `NotImplementedError` by design, so no fabricated
  summary is ever served; `/custom/ping` and `/cog/info` work as written).
- The generated API docs list both the `/cog/*` routes and the
  `/custom/*` routes.

Exact import paths and factory options are to confirm at validation
against TiTiler 0.25.0; the structure in `app.py` is the design
expectation, not a recorded run.

## Failure behavior

- Invalid input: a non-existent `bidx`, a missing `url`, or an
  unreadable `<COG_URL>` passed to `/custom/band-summary` is expected
  to produce an error response (HTTP 4xx/5xx) and no summary, rather
  than a summary for a different band or raster.
- No-result case: a COG with no data in the requested band, or a URL
  that resolves to a non-raster, is expected to error rather than
  return a fabricated summary with zeroed statistics. The exact status
  code is to confirm at validation.
- If the custom router fails to mount (for example, an import error at
  startup), the application fails to start loudly instead of silently
  serving only the stock routes — check startup logs before probing.

## Evidence

Evidence: design-only, gate 1 target.

This pattern has not been run and is not runtime-validated. No run log,
screenshot, or live response is claimed.

## Gate-3 proof

What would prove runtime validation: first complete the
statistics-delegation TODO in `app.py` against TiTiler 0.25.0, then run
`uvicorn app:app` with TiTiler 0.25.0 in a Python 3.11+ venv on Node-1
or Node-3 — the nodes where stock `/healthz` and `/redoc` were verified
per the seed — using `inputs/generate_cog.py`, and record the
`/custom/ping`, `/cog/info`, and `/custom/band-summary` responses
(status codes and key fields) plus a docs listing showing both `/cog/*`
and `/custom/*` routes. The stack is not claimed to be deployed end-to-end beyond what
this run would show.
