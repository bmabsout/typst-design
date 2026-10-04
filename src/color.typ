// COLOR: every color in the system is a sample of a ramp.
//
// A ramp is a straight line through OKLCH: from black (or near it) to white
// (or near it) at one hue, with chroma and hue allowed to drift along the way.
// Nothing is picked freehand: a color is named by its ramp and a position
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
///   is `oklch`, and `oklab` gives a straighter path through gray.
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

/// A whole identity ramp from ONE color: the ramp whose strong sample (30%)
/// is exactly `color`. Lightness runs in a straight line to white, chroma
/// fades to `end-chroma`, and the hue warms by `hue-shift` along the way,
/// as maroon's does. Every other tone (headings, washes, rules, marks) then
/// follows from the sampling rules, so a document's whole palette changes
/// with this one argument. A color darker than 30% lightness gets a ramp
/// that starts at black and ends short of white.
#let ramp-from(color, hue-shift: 15deg, end-chroma: 5%, at: 30%) = {
  let (l, c, h, ..) = oklch(color).components()
  let t = at / 100%
  let c1 = if type(end-chroma) == ratio { end-chroma / 100% * 0.4 } else { end-chroma }
  let c0 = calc.max(0, (c - t * c1) / (1 - t))
  let h0 = h - t * hue-shift
  let (l0, l1) = if l >= at {
    ((l - at) / (1 - t), 100%)
  } else {
    (0%, l / t)
  }
  gradient.linear(space: oklch, oklch(l0, c0, h0), oklch(l1, c1, h0 + hue-shift))
}

/// The hues the identity is built on, in degrees around OKLCH.
#let hues = (
  maroon: 5deg,
  blue: 256deg,
  rose: -14deg,
  teal: 166deg,
  orange: 43deg,
  amber: 48deg,
  sienna: 50deg,
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
/// - `sienna`: an identity ramp like maroon, in a brownish orange.
#let ramps = (
  maroon: ramp(hues.maroon, chroma: (60%, 5%), hue-shift: 15deg),
  blue: ramp(hues.blue, chroma: 0.116),
  rose: ramp(hues.rose, chroma: 0.124),
  teal: ramp(hues.teal, chroma: 0.104),
  // `ramp` always names a space. This one was written without one, so it
  // interpolates in Typst's default (OKLab) and is spelled out to stay so.
  orange: gradient.linear(oklch(0%, 73%, hues.orange), oklch(100%, 73%, hues.orange)),
  amber: ramp(hues.amber, chroma: (50%, 70%), lightness: (0%, 70%), hue-shift: 10deg),
  // An identity ramp built like maroon, in burnt orange: its dark end starts
  // at 12% lightness, so the strong sample reads as brownish orange rather
  // than near black.
  sienna: ramp(hues.sienna, chroma: (45%, 5%), lightness: (12%, 100%), hue-shift: 10deg),
  // Constant-chroma ramps that complete the chart's six slots.
  rust: ramp(43deg, chroma: 0.143),
  violet: ramp(300deg, chroma: 0.12),
  gold: ramp(89deg, chroma: 0.108),
  // Pure neutral, for a compliance mode that wants black headings
  // (Boston University's thesis office) without changing any code path.
  black: gradient.linear(space: oklch, black, black),
)

/// A flat gray for cross-references in compliance mode: black at every
/// sample, with a hue so it still reads as a ramp.
#let ref-ramp = ramp(-20deg, chroma: 0%, lightness: (0%, 0%), hue-shift: 10deg)

// ---------------------------------------------------------------- samples --

/// Where on a ramp each job samples. Three rules place every color:
///
/// - INK TONES sit on a 15% grid of depth: 15% for text on a wash of the
///   same ramp, 30% strong (the identity, heading 1, a callout's title), 45%
///   medium (heading 2, a supplement, a notice, the role colors,
///   references), 60% soft (heading 3, chart marks).
/// - RUNNING TEXT sits at medium or deeper, so it keeps 4.5:1 contrast on
///   paper in every ramp. Soft is for large text and marks only.
/// - QUIET TONES sit near white, at 80% (a mark's line), 90% (rules,
///   outlines) and 97% (fills), drawn with `quiet`.
///
/// These are light-theme positions. A dark theme mirrors them (`mirror`).
#let stops = (
  ink: 15%,
  strong: 30%,
  medium: 45%,
  soft: 60%,
  line: 80%,
  rule: 90%,
  fill: 97%,
)

/// Each job, by the tier it samples.
#let jobs = (
  heading-1: stops.strong,
  heading-2: stops.medium,
  heading-3: stops.soft,
  title: stops.strong,
  supplement: stops.medium,
  notice: stops.medium,
  role: stops.medium,
  ref: stops.medium,
)

/// The same job on a dark ground: the sample mirrored across the ramp.
#let mirror(t) = 100% - t

/// The dark theme's paper.
#let paper-dark = rgb("#1b1718")

/// Where a light-theme stop samples on a dark ground: the ink grid mirrored
/// into the space between the dark paper and white, so text keeps the same
/// contrast steps it has on white paper.
#let dark-stop(t, ground: paper-dark) = {
  let lp = oklch(ground).components().at(0) / 100%
  (1 - (t / 100%) * (1 - lp)) * 100%
}

/// A sample with its chroma scaled by `chroma` (1 = as sampled).
#let shade(g, t, chroma: 100%) = {
  let (l, c, h, ..) = oklch(g.sample(t)).components()
  oklch(l, c * (chroma / 100%), h)
}

/// How much color a quiet tone may carry: its distance from white times
/// this. The same for every ramp, so a rose wash is exactly as quiet as a
/// blue one.
#let quietness = 0.35

/// A quiet tone: the ramp's sample at `t`, its lightness and hue kept, its
/// chroma capped at `quietness × (1 − lightness)`.
#let quiet(g, t) = {
  let (l, c, h, ..) = oklch(g.sample(t)).components()
  oklch(l, calc.min(c, quietness * (1 - l / 100%)), h)
}

/// A quiet tone on a dark ground: as far above the dark paper as `quiet`
/// sits below white, with chroma capped the same way.
#let quiet-dark(g, t, ground: paper-dark) = {
  let lp = oklch(ground).components().at(0) / 100%
  let d = (1 - t / 100%) * 1.6
  let (l, c, h, ..) = oklch(g.sample(t)).components()
  oklch((lp + d) * 100%, calc.min(c, quietness * d), h)
}

/// The tones a callout draws from its ramp: a quiet fill and outline, a
/// strong title, a medium supplement and notice, and ink for the text.
#let tones(g) = (
  wash: quiet(g, stops.fill),
  line: quiet(g, stops.rule),
  title: g.sample(jobs.title),
  supplement: g.sample(jobs.supplement),
  ink: g.sample(stops.ink),
  notice: g.sample(jobs.notice),
)

/// The callout tones the dissertation was set in, before the rules above:
/// kept so it prints identically.
#let classic-tones(g) = (
  wash: g.sample(80%).desaturate(85%).lighten(85%),
  line: g.sample(80%).desaturate(50%).lighten(50%),
  title: g.sample(35%),
  supplement: g.sample(40%),
  ink: g.sample(15%),
  notice: g.sample(50%),
)

// ------------------------------------------------------------------ roles --

/// The three role colors: what is observed (states, inputs), what is acted
/// (actions, outputs) and what is valued (rewards, objectives). The same
/// color marks a role in prose, in equations and in plots.
#let roles = (
  observed: ramps.blue.sample(jobs.role),
  acted: ramps.rose.sample(jobs.role),
  valued: ramps.teal.sample(jobs.role),
)

// ---------------------------------------------------------------- palette --

/// The identity's named colors on paper, each a sample or a quiet tone of
/// the maroon ramp.
///
/// - `primary`, `secondary`: the strong and medium samples.
/// - `ink`, `ink-muted`: the near-black body text and its secondary.
/// - `mark-fill`, `rule`, `mark-line`: the quiet tones at 97%, 90% and 80%:
///   panels and the diamond's fill, the capsule rule, the diamond's outline.
#let palette = (
  primary: ramps.maroon.sample(stops.strong),
  secondary: ramps.maroon.sample(stops.medium),
  ink: oklch(28.91%, 0, 0deg),
  ink-muted: oklch(45.68%, 0, 0deg),
  paper: white,
  mark-fill: quiet(ramps.maroon, stops.fill),
  rule: quiet(ramps.maroon, stops.rule),
  mark-line: quiet(ramps.maroon, stops.line),
)

/// The fulfillment scale (FPL): a value in [0, 1] as a color, bad to good.
/// Low is urgent. Five OKLCH stops: the crimson of the identity, copper,
/// amber, green, and the teal of the `valued` role. Lightness stays between
/// 44% and 64%, so every sample keeps 3:1 contrast on paper, enough for
/// marks and bold labels. Bad is darker than good and good leans blue, so
/// the two ends still part for red–green color-blind readers.
#let fulfillment = gradient.linear(
  space: oklch,
  (oklch(44%, 0.16, 14deg), 0%),
  (oklch(60%, 0.15, 45deg), 33%),
  (oklch(64%, 0.13, 82deg), 58%),
  (oklch(62%, 0.13, 145deg), 78%),
  (oklch(58%, 0.11, 185deg), 100%),
)

/// Categorical series colors in a fixed order, never cycled: six
/// constant-chroma ramps sampled alternately soft (60%) and medium (45%), so
/// neighbors differ in lightness as well as hue, the cue color-blind
/// readers rely on. The first three are the roles' ramps.
#let chart = (
  ramps.blue.sample(stops.soft),
  ramps.rose.sample(stops.medium),
  ramps.teal.sample(stops.soft),
  ramps.rust.sample(stops.medium),
  ramps.violet.sample(stops.soft),
  ramps.gold.sample(stops.medium),
)

// ----------------------------------------------------------------- tools --

/// A strip of a gradient's samples, to look at a ramp as it really samples
/// (a gradient fill is redrawn by the viewer and can differ out of gamut).
/// Neighboring cells overlap a hair so no seam shows between them.
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
