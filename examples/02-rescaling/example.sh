#!/usr/bin/env bash
# 02-rescaling — rescale float rasters so tiles render (design-only draft).
# Fill in the placeholders before running. No credentials are used here.
set -euo pipefail

TITILER_URL="${TITILER_URL:-<TITILER_URL>}"
COG_URL="${COG_URL:-<COG_URL>}"
Z="${Z:-0}"
X="${X:-0}"
Y="${Y:-0}"
# Set these from the /cog/statistics output below (min,max of the band).
RESCALE_MIN="${RESCALE_MIN:-<MIN>}"
RESCALE_MAX="${RESCALE_MAX:-<MAX>}"

echo "== statistics (read the real range first) =="
curl -fsS "${TITILER_URL}/cog/statistics?url=${COG_URL}"
echo

echo "== tile WITHOUT rescale (control case) =="
curl -fsS -o /tmp/titiler-02-tile-unscaled.png \
  "${TITILER_URL}/cog/tiles/${Z}/${X}/${Y}.png?url=${COG_URL}" \
  || echo "NOTE: unscaled request failed (see Failure behavior in README.md)"
file /tmp/titiler-02-tile-unscaled.png 2>/dev/null || true

echo "== tile WITH rescale =="
curl -fsS -o /tmp/titiler-02-tile-rescaled.png \
  "${TITILER_URL}/cog/tiles/${Z}/${X}/${Y}.png?url=${COG_URL}&rescale=${RESCALE_MIN},${RESCALE_MAX}"
file /tmp/titiler-02-tile-rescaled.png
echo "Unscaled: /tmp/titiler-02-tile-unscaled.png"
echo "Rescaled: /tmp/titiler-02-tile-rescaled.png"

echo "== invalid rescale (expected error, not a silent mis-scale) =="
curl -sS -o /tmp/titiler-02-tile-bad-rescale.out -w "HTTP %{http_code}\n" \
  "${TITILER_URL}/cog/tiles/${Z}/${X}/${Y}.png?url=${COG_URL}&rescale=not-a-number" \
  || true
cat /tmp/titiler-02-tile-bad-rescale.out
