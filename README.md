# TiTiler Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **TiTiler cookbook** for serving cloud-native rasters as dynamic map tiles, STAC endpoints, and statistics APIs. Patterns are drawn from the ZQM fleet's running TiTiler 0.25.0 installs (verified `/healthz` and `/redoc` on Node-1 and Node-3, serving sample COGs with tile and info endpoints). It is intended for GIS engineers and data engineers who serve imagery without pre-rendering tiles; validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — seeding. Pattern passes land in follow-up work from fleet-verified setups; the tables below list what is planned, not what is already written.

**What this repository is:** TiTiler patterns — COG tile serving, rescaling, STAC-backed endpoints, and statistics, against local files and object storage.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Geospatial developers and cloud engineers who store imagery as Cloud Optimized GeoTIFFs and want on-the-fly tiles, previews, and band statistics instead of a tile cache.

## Prerequisites

- TiTiler 0.25.0 (Python virtual environment; application entry `titiler.application.main:app`)
- Python 3.11+
- A COG to serve (see [cog-cookbook](https://github.com/ZQM-Computing/cog-cookbook) for creating one)
- Bash

## Patterns (planned)

| # | Example | What it will demonstrate |
|---|---------|--------------------------|
| 01 | `01-cog-tiles` | Serving a local COG as XYZ tiles, with `/cog/info` and tile endpoints |
| 02 | `02-rescaling` | Rescaling float rasters (`rescale` parameters) so tiles render instead of failing |
| 03 | `03-stac-endpoints` | STAC-backed tile and statistics endpoints against a pgSTAC catalog |
| 04 | `04-statistics` | Band statistics and histograms over a window, without reading the whole raster |
| 05 | `05-custom-application` | Extending the TiTiler application with a custom endpoint factory |
| 06 | `06-full-workflow` | End-to-end: COG → catalog → tiles → statistics |

## Repository layout

```text
titiler-cookbook/
├── examples/          # pattern passes, landing in follow-up work
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: COG tiles + rescaling (01, 02)
- Second pass: STAC endpoints + statistics (03, 04), paired with pgstac-cookbook
- Custom application pass (05) once the fleet's TiTiler deployment patterns are written up

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [cog-cookbook](https://github.com/ZQM-Computing/cog-cookbook) — Cloud Optimized GeoTIFF creation, validation, TiTiler serving, xarray integration
- [pgstac-cookbook](https://github.com/ZQM-Computing/pgstac-cookbook) — STAC catalogs in PostGIS, stac-fastapi APIs, bulk ingest
- [stac-cookbook](https://github.com/ZQM-Computing/stac-cookbook) — STAC catalog creation, item validation, search API, bulk ops
