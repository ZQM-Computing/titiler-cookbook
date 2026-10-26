"""05-custom-application — extend TiTiler with a custom endpoint factory.

Design-only draft for TiTiler 0.25.0, Python 3.11+.
Import paths and factory options are written against TiTiler 0.25.0's
documented factory API and are TO CONFIRM AT VALIDATION before running.

Run (host/port are placeholders):
    uvicorn app:app --host <HOST> --port <PORT>

No credentials are used here. The COG URL is passed per request.
"""

from fastapi import APIRouter, FastAPI, Query
from titiler.core.factory import TilerFactory

# Stock TiTiler COG endpoints, mounted unchanged.
app = FastAPI(title="TiTiler custom application (pattern 05)")
cog = TilerFactory()
app.include_router(cog.router, prefix="/cog")

# Custom router: our own endpoints living beside the stock ones.
custom = APIRouter(prefix="/custom", tags=["custom"])


@custom.get("/ping")
def ping():
    """Prove the custom router is mounted."""
    return {"status": "ok", "app": "titiler-custom-pattern-05"}


@custom.get("/band-summary")
def band_summary(
    url: str = Query(..., description="URL of a COG, e.g. <COG_URL>"),
    bidx: int = Query(1, description="1-based band index"),
):
    """Reduced per-band summary, wrapping the stock statistics logic.

    Implementation note (to confirm at validation): the cleanest
    implementation delegates to the same reader/statistics path the
    TilerFactory statistics endpoint uses, then returns only
    {bidx, min, max, mean}. The placeholder body below keeps this file
    importable and honest about what is not yet wired: replace the
    body with the delegated statistics call at validation, and do not
    ship zeroed statistics as if they were measured.
    """
    # TODO at validation: call the TiTiler COG statistics reader for
    # (url, bidx) and return {"bidx": bidx, "min": ..., "max": ...,
    # "mean": ...}. Raising here until that wiring is validated keeps
    # a bad summary from ever being served as real data.
    raise NotImplementedError(
        "band-summary statistics delegation to confirm at validation "
        "against TiTiler 0.25.0; see README.md Failure behavior."
    )


app.include_router(custom)
