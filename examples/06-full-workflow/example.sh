#!/usr/bin/env bash
# 06-full-workflow — COG -> catalog -> tiles -> statistics (design-only draft).
# Fill in the placeholders before running. No credentials are used here.
# The catalog interaction is via documented API calls with placeholders,
# not a live catalog. Endpoint/payload spellings to confirm at validation.
set -euo pipefail

TITILER_URL="${TITILER_URL:-<TITILER_URL>}"
STAC_API_URL="${STAC_API_URL:-<STAC_API_URL>}"
COG_URL="${COG_URL:-<COG_URL>}"
COLLECTION_ID="${COLLECTION_ID:-<COLLECTION_ID>}"
ITEM_ID="${ITEM_ID:-<ITEM_ID>}"
Z="${Z:-0}"
X="${X:-0}"
Y="${Y:-0}"

ITEM_URL="${STAC_API_URL}/collections/${COLLECTION_ID}/items/${ITEM_ID}"

echo "== 1. titiler health =="
curl -fsS "${TITILER_URL}/healthz"
echo

echo "== 2. register item in catalog (payload template: inputs/register-item-template.json) =="
# Substitute <COG_URL>, <COLLECTION_ID>, <ITEM_ID> into the template first.
# Exact POST path and required fields to confirm at validation.
sed -e "s|<COG_URL>|${COG_URL}|g" \
    -e "s|<COLLECTION_ID>|${COLLECTION_ID}|g" \
    -e "s|<ITEM_ID>|${ITEM_ID}|g" \
    inputs/register-item-template.json > /tmp/titiler-06-item.json
curl -fsS -X POST -H "Content-Type: application/json" \
  --data @/tmp/titiler-06-item.json \
  "${STAC_API_URL}/collections/${COLLECTION_ID}/items"
echo

echo "== 3. read item back =="
curl -fsS "${ITEM_URL}"
echo

echo "== 4. stac bounds / info / tilejson =="
curl -fsS "${TITILER_URL}/stac/bounds?url=${ITEM_URL}"
echo
curl -fsS "${TITILER_URL}/stac/info?url=${ITEM_URL}"
echo
curl -fsS "${TITILER_URL}/stac/tilejson.json?url=${ITEM_URL}"
echo

echo "== 5. stac tile (PNG) =="
curl -fsS -o /tmp/titiler-06-tile.png \
  "${TITILER_URL}/stac/tiles/${Z}/${X}/${Y}.png?url=${ITEM_URL}"
file /tmp/titiler-06-tile.png

echo "== 6. stac statistics =="
curl -fsS "${TITILER_URL}/stac/statistics?url=${ITEM_URL}"
echo

echo "== 7. direct cog statistics (cross-check) =="
curl -fsS "${TITILER_URL}/cog/statistics?url=${COG_URL}"
echo
echo "Compare step 6 vs step 7: same-band values must agree (see README.md)."
