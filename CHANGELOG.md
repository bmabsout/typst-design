# Changelog

All notable changes to this package are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `flow-block`: a rounded callout block that breaks across pages, rounded only
  where it really starts and ends. It is the default callout engine.
- `callout-rules`: the document rule that lets callout figures break.
- `frame`, `frame-rules` and `frame-layer`: a second page-spanning engine.
  The block records where it starts and ends, and the page background draws
  each page's piece as one shape, so a dashed outline has no seams at the
  corners. Opt in with `callouts(engine: frame)` and `#show: frame-rules`.
- `ramp-from(color)`: a whole identity ramp grown from one color, whose
  strong sample is that color. `cv-style(ramp:)` accepts a color too.
- Sampling rules: ink tones on a 15% grid (`stops.ink`, `strong`, `medium`,
  `soft`) and quiet tones by `quiet(g, t)`, whose chroma is at most
  `quietness × (1 − lightness)`. `jobs` maps each job to its stop. Running
  text (roles, references) sits at medium or deeper, and the laws check
  4.5:1 contrast for it in every ramp.
- `callouts(classic: true)` and `classic-tones` reproduce the original
  callouts exactly.
- `ramps.sienna`, an identity ramp in brownish orange.
- CV kit: `section` (breaks gently), `wrapping-heading`, `row`, `row-list`,
  `labeled-rows` and `talk`. `contact-box` takes any number of items and
  icons given as content. `header` takes a fixed date. `authors` and
  `publication-entry` take author arrays, an exact `owner`, an optional DOI
  and a note.
- Examples (`examples/`), checked by `nix flake check`.
- A rule-based dark theme: `paper-dark`, `dark-stop(t)` for text tones and
  `quiet-dark(g, t)` for quiet ones. The laws check 4.5:1 on the dark ground.
- `scripts/images.py` renders the README's images from the examples and the
  gallery.

### Fixed
- `flow-block` no longer leaves its rounded top edge alone at the bottom of a
  page when the callout starts there. The top edge, the padding and the title
  now stay with the first line of text.

### Changed
- The fulfillment scale now runs crimson → copper → amber → green → teal.
  Every sample keeps 3:1 contrast on paper, and the ends part for
  color-blind readers.
- Role colors, chart slots, callout tones and the blush (`mark-fill`, `rule`,
  `mark-line`) follow the sampling rules. `palette.rule-soft` is merged into
  `palette.rule`.
- CV links align with the entry's text, and publications use the entries'
  leading.
- The CV and résumé kits take the name to bold in author lists as `owner`.

## [0.1.0] - 2026-10-03

### Added
- Ramps, palette, roles, chart slots and the fulfillment scale.
- Capsule rule, diamond, callouts, role-colored math and abbreviations.
- Fulfillment marks: `pie`, `price` and `trace`.
- Templates: thesis, CV, résumé, statement and working document.
- Gallery, laws and a Nix flake.
