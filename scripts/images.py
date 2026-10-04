#!/usr/bin/env python3
"""Render the README's images in docs/images from the examples and the gallery.

Run from the repository root, with `typst` on PATH and the fonts it needs:
    python3 scripts/images.py
Extra arguments go to every `typst compile`, for example `--font-path fonts`.
Needs Pillow.
"""
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

PAPER_GAP = (236, 230, 230)  # the gray between pages
EDGE, GUTTER = 8, 16

# (image, source, pixels per inch, pages placed side by side)
IMAGES = [
    ("quickstart", "examples/quickstart.typ", 144, [1]),
    ("cv", "examples/cv.typ", 110, [1]),
    ("page-spanning-callout", "examples/page-spanning-callout.typ", 90, [1, 2]),
    ("gallery", "gallery/gallery.typ", 72, [1, 2]),
]


def render(source, ppi, out, extra):
    subprocess.run(
        ["typst", "compile", "--root", ".", "--ppi", str(ppi), *extra, source, str(out / "page-{p}.png")],
        check=True,
    )
    return sorted(out.glob("page-*.png"), key=lambda p: int(p.stem.split("-")[1]))


def side_by_side(pages):
    width = sum(p.width for p in pages) + 2 * EDGE + GUTTER * (len(pages) - 1)
    sheet = Image.new("RGB", (width, max(p.height for p in pages)), PAPER_GAP)
    x = EDGE
    for p in pages:
        sheet.paste(p, (x, 0))
        x += p.width + GUTTER
    return sheet


def main():
    extra = sys.argv[1:]
    Path("docs/images").mkdir(parents=True, exist_ok=True)
    for name, source, ppi, wanted in IMAGES:
        with tempfile.TemporaryDirectory() as tmp:
            files = render(source, ppi, Path(tmp), extra)
            pages = [Image.open(files[i - 1]).convert("RGB") for i in wanted]
            image = pages[0] if len(pages) == 1 else side_by_side(pages)
            image.save(f"docs/images/{name}.png", optimize=True)
        print(f"docs/images/{name}.png")


if __name__ == "__main__":
    main()
