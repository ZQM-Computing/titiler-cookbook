#!/usr/bin/env bash
# 01-cog-tiles — serve a local COG as XYZ tiles (design-only draft).
# Fill in the placeholders before running. No credentials are used here.
# Requires: a running TiTiler 0.25.0 instance and a COG reachable at COG_URL.
set -euo pipefail

TITILER_URL="${TITILER_URL:-<TITILER_URL>}"
COG_URL="${COG_URL:-<COG_URL>}"
# Example tile: zoom/x/y inside the synthetic COG's bounds.
# Adjust after reading /cog/bounds output.
Z="${Z:-0}"
X="${X:-0}"
Y="${Y:-0}"

echo "== health =="
curl -fsS "${TITILER_URL}/healthz"
echo

echo "== cog info =="
curl -fsS "${TITILER_URL}/cog/info?url=${COG_URL}"
echo

echo "== cog bounds =="
curl -fsS "${TITILER_URL}/cog/bounds?url=${COG_URL}"
echo

echo "== tilejson =="
curl -fsS "${TITILER_URL}/cog/tilejson.json?url=${COG_URL}"
echo

echo "== one tile (PNG) =="
curl -fsS -o /tmp/titiler-01-tile.png \
  "${TITILER_URL}/cog/tiles/${Z}/${X}/${Y}.png?url=${COG_URL}"
file /tmp/titiler-01-tile.png
echo "Tile saved to /tmp/titiler-01-tile.png"
