# inputs/ — 03-stac-endpoints

- `example-item.json` is a SYNTHETIC STAC item document for shape
  reference only. It is not a live catalog record and its hrefs are
  placeholders (`<ITEM_ID>`, `<COLLECTION_ID>`, `<COG_URL>`).
- The pgSTAC catalog interaction in this pattern is via documented API
  calls with placeholders (see `example.sh`), not a live catalog.
- No credentials are included anywhere in this pattern.
- To use this pattern at validation, register a real synthetic item in
  a pgSTAC 0.10.0 / stac-fastapi.pgstac 7.1.0 catalog and substitute its
  collection/item IDs for the placeholders.
