#!/usr/bin/env bash
# 03-stac-endpoints — STAC-backed tiles + statistics (design-only draft).
# Fill in the placeholders before running. No credentials are used here.
# The catalog interaction is via documented API calls with placeholders,
# not a live catalog. Endpoint spellings to confirm at validation.
set -euo pipefail

TITILER_URL="${TITILER_URL:-<TITILER_URL>}"
STAC_API_URL="${STAC_API_URL:-<STAC_API_URL>}"
COLLECTION_ID="${COLLECTION_ID:-<COLLECTION_ID>}"
ITEM_ID="${ITEM_ID:-<ITEM_ID>}"
Z="${Z:-0}"
X="${X:-0}"
Y="${Y:-0}"

# TiTiler STAC endpoints address an item through its catalog URL.
ITEM_URL="${STAC_API_URL}/collections/${COLLECTION_ID}/items/${ITEM_ID}"

echo "== catalog item lookup =="
curl -fsS "${ITEM_URL}"
echo

echo "== stac bounds =="
curl -fsS "${TITILER_URL}/stac/bounds?url=${ITEM_URL}"
echo

echo "== stac info =="
curl -fsS "${TITILER_URL}/stac/info?url=${ITEM_URL}"
echo

echo "== stac tilejson =="
curl -fsS "${TITILER_URL}/stac/tilejson.json?url=${ITEM_URL}"
echo

echo "== stac tile (PNG) =="
curl -fsS -o /tmp/titiler-03-tile.png \
  "${TITILER_URL}/stac/tiles/${Z}/${X}/${Y}.png?url=${ITEM_URL}"
file /tmp/titiler-03-tile.png

echo "== stac statistics =="
curl -fsS "${TITILER_URL}/stac/statistics?url=${ITEM_URL}"
echo
echo "Tile saved to /tmp/titiler-03-tile.png"
