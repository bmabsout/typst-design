// COLOUR — every colour in the system is a sample of a ramp.
//
// A ramp is a straight line through OKLCH: from black (or near it) to white
// (or near it) at one hue, with chroma and hue allowed to drift along the way.
// Nothing is picked freehand: a colour is named by its ramp and a position
// (`maroon.sample(30%)`), and the hex it prints is an output, never an input.
// Changing the identity is changing a ramp's few numbers, and every heading,
// rule, callout and plot follows.

// ------------------------------------------------------------------ ramps --

/// A ramp: a linear OKLCH gradient from `(lightness.at(0), chroma.at(0), hue)`
/// to `(lightness.at(1), chroma.at(1), hue + hue-shift)`.
///
/// - `chroma` is a pair, or one value for a constant chroma. Typst reads a
///   ratio as a share of 0.4 (so `60%` is 0.24) and a float as itself.
/// - `space` is the space the gradient interpolates in. Every identity ramp
///   is `oklch`; `oklab` gives a straighter path through grey.
#let ramp(
  hue,
  chroma: 0.12,
  lightness: (0%, 100%),
  hue-shift: 0deg,
  space: oklch,
) = {
  let (c0, c1) = if type(chroma) == array { chroma } else { (chroma, chroma) }
  let (l0, l1) = lightness
  gradient.linear(space: space, oklch(l0, c0, hue), oklch(l1, c1, hue + hue-shift))
}

/// The hues the identity is built on, in degrees around OKLCH.
#let hues = (
  maroon: 5deg,
  blue: 256deg,
  rose: -14deg,
  teal: 166deg,
  orange: 43deg,
  amber: 48deg,
)

/// The named ramps.
///
/// - `maroon`: the identity. Deep and saturated at the dark end, warming
///   toward a pale blush at the light end. Headings, labels, links, rules.
/// - `blue`, `rose`, `teal`: the three role ramps (observed, acted, valued),
///   constant chroma so their mid-samples sit at matching weight.
/// - `orange`: warnings. Interpolated in OKLab (as the thesis always has), so
///   its middle is a little more muted than an OKLCH line would be.
/// - `amber`: a short ramp that stops at 70% lightness, for strong accents.
#let ramps = (
  maroon: ramp(hues.maroon, chroma: (60%, 5%), hue-shift: 15deg),
  blue: ramp(hues.blue, chroma: 0.116),
  rose: ramp(hues.rose, chroma: 0.124),
  teal: ramp(hues.teal, chroma: 0.104),
  // `ramp` always names a space; this one was written without one, so it
  // interpolates in Typst's default (OKLab) and is spelled out to stay so.
  orange: gradient.linear(oklch(0%, 73%, hues.orange), oklch(100%, 73%, hues.orange)),
  amber: ramp(hues.amber, chroma: (50%, 70%), lightness: (0%, 70%), hue-shift: 10deg),
  // Constant-chroma ramps that complete the chart's six slots.
  rust: ramp(43deg, chroma: 0.143),
  violet: ramp(300deg, chroma: 0.12),
  gold: ramp(89deg, chroma: 0.108),
  // Pure neutral, for a compliance mode that wants black headings
  // (Boston University's thesis office) without changing any code path.
  black: gradient.linear(space: oklch, black, black),
)

/// A flat grey for cross-references in compliance mode: black at every
/// sample, with a hue so it still reads as a ramp.
#let ref-ramp = ramp(-20deg, chroma: 0%, lightness: (0%, 0%), hue-shift: 10deg)

// ---------------------------------------------------------------- samples --

/// Where on a ramp each job samples. Light-theme positions; a dark theme
/// mirrors them (`mirror`).
#let stops = (
  ink: 15%,        // text set on a wash of the same ramp
  heading-1: 30%,  // the identity: brand colour and chapter titles
  title: 35%,      // a callout's title
  supplement: 40%, // a callout's figure supplement ("Theorem")
  heading-2: 45%,
  notice: 50%,     // the "Notice:" label
  role: 55%,       // a role colour in text, symbols and plots
  ref: 60%,
  heading-3: 60%,
  rule: 90%,       // the capsule rule
  frame: 80%,      // the base a callout's wash and line are derived from
)

/// The same job on a dark ground: the sample mirrored across the ramp.
#let mirror(t) = 100% - t

/// A sample with its chroma scaled by `chroma` (1 = as sampled) — the way to
/// get a quieter tone of a ramp at an exact lightness without leaving it.
#let shade(g, t, chroma: 100%) = {
  let (l, c, h, ..) = oklch(g.sample(t)).components()
  oklch(l, c * (chroma / 100%), h)
}

/// The tones a callout draws from one ramp (the thesis's `note`): a wash to
/// fill, a line to outline, a title, a supplement and the text.
#let tones(g) = (
  wash: g.sample(stops.frame).desaturate(85%).lighten(85%),
  line: g.sample(stops.frame).desaturate(50%).lighten(50%),
  title: g.sample(stops.title),
  supplement: g.sample(stops.supplement),
  ink: g.sample(stops.ink),
  notice: g.sample(stops.notice),
)

// ------------------------------------------------------------------ roles --

/// The three role colours: what is observed (states, inputs), what is acted
/// (actions, outputs) and what is valued (rewards, objectives). The same
/// colour marks a role in prose, in equations and in plots.
#let roles = (
  observed: ramps.blue.sample(stops.role),
  acted: ramps.rose.sample(stops.role),
  valued: ramps.teal.sample(stops.role),
)

// ---------------------------------------------------------------- palette --

/// The identity's named colours on paper. Each is a ramp sample or a shade
/// of one.
///
/// - `primary`: the maroon heading-1 sample; brand and hierarchy are one.
/// - `secondary`: the heading-2 sample, for a subsection or second level.
/// - `ink`, `ink-muted`: the near-black body text and its secondary.
/// - `mark-fill`, `mark-line`, `rule-soft`: the blush the diamond, the
///   contact panel and the CV's rule are drawn in — quiet shades of maroon
///   at 97%, 82% and 91% lightness.
/// - `rule`: the capsule rule of long documents, maroon's 90% sample.
#let palette = (
  primary: ramps.maroon.sample(stops.heading-1),
  secondary: ramps.maroon.sample(stops.heading-2),
  ink: oklch(28.91%, 0, 0deg),
  ink-muted: oklch(45.68%, 0, 0deg),
  paper: white,
  mark-fill: shade(ramps.maroon, 97%, chroma: 35%),
  mark-line: shade(ramps.maroon, 82%, chroma: 80%),
  rule-soft: shade(ramps.maroon, 91%, chroma: 55%),
  rule: ramps.maroon.sample(stops.rule),
)

/// The fulfillment scale (FPL): a value in [0, 1] as a colour, bad to good.
/// Low is urgent. Five OKLCH stops: the crimson of the identity, copper,
/// amber, green, and the teal of the `valued` role. Two things make it
/// readable. Lightness stays between 44% and 70%, so every sample can colour
/// text on paper. Bad is darker than good and good leans blue, so the two
/// ends still part for red–green colour-blind readers.
#let fulfillment = gradient.linear(
  space: oklch,
  (oklch(44%, 0.16, 14deg), 0%),
  (oklch(60%, 0.15, 45deg), 33%),
  (oklch(70%, 0.13, 82deg), 58%),
  (oklch(65%, 0.13, 145deg), 78%),
  (oklch(58%, 0.11, 185deg), 100%),
)

/// Categorical series colours in a fixed order, never cycled. Each is a
/// constant-chroma ramp sampled at 63% or 48% lightness, alternating so
/// neighbours differ in lightness as well as hue (the test colour-blind
/// readers need). The first three are the roles.
#let chart = (
  ramps.blue.sample(63%),
  ramps.rose.sample(48%),
  ramps.teal.sample(63%),
  ramps.rust.sample(48%),
  ramps.violet.sample(48%),
  ramps.gold.sample(53%),
)

// ----------------------------------------------------------------- tools --

/// A strip of a gradient's samples, to look at a ramp as it really samples
/// (a gradient fill is redrawn by the viewer and can differ out of gamut).
/// Neighbouring cells overlap a hair so no seam shows between them.
#let swatch(fill, width: 10em, height: 2em, samples: 100) = {
  let at(i) = if type(fill) == gradient { fill.sample(i * 100% / calc.max(1, samples - 1)) } else { fill }
  layout(size => {
    let w = if type(width) == ratio or type(width) == relative { (width * size.width).to-absolute() } else { width.to-absolute() }
    let step = w / samples
    box(width: w, height: height, clip: true, for i in range(samples) {
      place(dx: step * i, rect(width: step + 0.4pt, height: height, fill: at(i), stroke: none))
    })
  })
}
