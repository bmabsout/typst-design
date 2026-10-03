// typst-design: Bassel El Mabsout's design system for Typst.
//
//   #import "@local/typst-design:0.1.0": *
//
// Everything is reachable two ways: flat (the names below), and by module
// (`colors.ramps`, `rlmath.state`, `templates.thesis.make-template`). Names
// that would shadow Typst's own (`state`, `color`, `math`, `document`,
// `figure`) are only reachable through their module.

#import "src/color.typ" as colors
#import "src/type.typ" as typography
#import "src/marks.typ" as marks
#import "src/callouts.typ" as callout
#import "src/math.typ" as rlmath
#import "src/icons.typ" as icons
#import "src/fpl.typ" as fpl
#import "src/figures.typ" as figures
#import "src/templates/cv.typ" as cv
#import "src/templates/resume.typ" as resume
#import "src/templates/statement.typ" as statement-template
#import "src/templates/thesis.typ" as thesis
#import "src/templates/document.typ" as working

#let templates = (
  cv: cv,
  resume: resume,
  statement: statement-template,
  thesis: thesis,
  document: working,
)

// Color.
#import "src/color.typ": ramp, hues, ramps, ref-ramp, stops, jobs, mirror, shade, quiet, quietness, tones, classic-tones, roles, palette, fulfillment, chart, swatch
// Type.
#import "src/type.typ": faces, ratio, scale, font-options, label-text, minor
// Marks.
#import "src/marks.typ": capsule, capsule-rule, diamond, sep
// Callouts.
#import "src/callouts.typ": seamless-block, flow-block, callouts, callout-rules, note, theorem, algorithm, notice
// Math.
#import "src/math.typ": observed, acted, valued, rl, pmean, fbox, vecand, vecor, loss, expect, policy, sigmoid, stack-math, make-abbrv, abbreviations, abbreviation-table
// Icons.
#import "src/icons.typ": fa, icon
// FPL marks.
#import "src/fpl.typ": fulfillment-color, percent, price, pie, trace, state-of
// Templates.
#import "src/templates/cv.typ": cv-style, cv-kit, cv-page
#import "src/templates/resume.typ": resume-style, resume-kit, resume-page
#import "src/templates/statement.typ": statement, title-line
#import "src/templates/thesis.typ": thesis-colors, thesis-style, heading-style, thesis-rule, local-outline, make-template
#import "src/templates/document.typ": section-title, panel, dated, accent
#let working-document = working.document
