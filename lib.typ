// typst-design: Bassel El Mabsout's design system for Typst.
//
//   #import "@local/typst-design:0.1.0": *
//
// Everything is reachable two ways: flat (the names below), and by module
// (`colors.ramps`, `rlmath.state`, `callout.flow-block`). Names
// that would shadow Typst's own (`state`, `color`, `math`, `document`,
// `figure`) are only reachable through their module.

#import "src/color.typ" as colors
#import "src/type.typ" as typography
#import "src/marks.typ" as marks
#import "src/callouts.typ" as callout
#import "src/span.typ" as spans
#import "src/frames.typ" as frames
#import "src/math.typ" as rlmath
#import "src/icons.typ" as icons
#import "src/fpl.typ" as fpl
#import "src/templates/document.typ" as working

// Color.
#import "src/color.typ": ramp, ramp-from, hues, ramps, ref-ramp, stops, jobs, mirror, paper-dark, dark-stop, shade, quiet, quiet-dark, quietness, apca, contrast, text-needs, reads, legibility, as-text, readable, tones, roles, palette, fulfillment, chart, swatch
// Type.
#import "src/type.typ": faces, ratio, scale, font-options, label-text, minor
// Marks.
#import "src/marks.typ": capsule, capsule-rule, diamond, sep
// Spans: a stretch of the flow marked only where it really starts and ends.
#import "src/span.typ": span, span-start, span-end
// Callouts.
#import "src/callouts.typ": flow-block, callouts, callout-rules, note, theorem, algorithm, notice
#import "src/frames.typ": frame, frame-layer, frame-rules
// Math.
#import "src/math.typ": observed, acted, valued, rl, pmean, fbox, vecand, vecor, loss, expect, policy, sigmoid, stack-math, make-abbrv, abbreviations, abbreviation-table
// Icons.
#import "src/icons.typ": fa, icon
// FPL marks.
#import "src/fpl.typ": fulfillment-color, percent, price, pie, trace, state-of
// The working document.
#import "src/templates/document.typ": section-title, panel, dated, accent
#let working-document = working.document
