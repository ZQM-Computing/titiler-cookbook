#!/usr/bin/env bash
# 04-statistics — band statistics + histograms over a window (design-only draft).
# Fill in the placeholders before running. No credentials are used here.
set -euo pipefail

TITILER_URL="${TITILER_URL:-<TITILER_URL>}"
COG_URL="${COG_URL:-<COG_URL>}"
# A window inside the COG's bounds: minx,miny,maxx,maxy (from /cog/bounds).
BBOX="${BBOX:-<BBOX>}"

echo "== full-raster statistics =="
curl -fsS "${TITILER_URL}/cog/statistics?url=${COG_URL}"
echo

echo "== windowed statistics (bbox only) =="
curl -fsS "${TITILER_URL}/cog/statistics?url=${COG_URL}&bbox=${BBOX}"
echo

echo "== single-band statistics (bidx=1) =="
curl -fsS "${TITILER_URL}/cog/statistics?url=${COG_URL}&bidx=1"
echo

echo "== histogram =="
curl -fsS "${TITILER_URL}/cog/histogram?url=${COG_URL}&bidx=1"
echo

echo "== invalid bbox (expected error, not full-raster statistics) =="
curl -sS -o /tmp/titiler-04-bad-bbox.out -w "HTTP %{http_code}\n" \
  "${TITILER_URL}/cog/statistics?url=${COG_URL}&bbox=not-a-bbox" || true
cat /tmp/titiler-04-bad-bbox.out
