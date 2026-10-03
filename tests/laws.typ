// The design system's laws. Compiling this file is the test: every
// `assert` must hold. Run: typst compile --root . tests/laws.typ /tmp/laws.pdf
#import "../lib.typ": *
#show: callout-rules

#let hex(c) = c.to-hex()
#let at(g, t) = hex(g.sample(t))

// 1. The ramps are the thesis's gradients, stop for stop. These literals are
//    the definitions in bmabsout/Thesis src/style.typ. A ramp that drifts
//    from them changes every page the thesis prints.
#let thesis = (
  maroon: gradient.linear(space: oklch, oklch(0%, 60%, 5deg), oklch(100%, 5%, 20deg)),
  blue: gradient.linear(space: oklch, oklch(0%, 0.116, 256deg), oklch(100%, 0.116, 256deg)),
  rose: gradient.linear(space: oklch, oklch(0%, 0.124, -14deg), oklch(100%, 0.124, -14deg)),
  teal: gradient.linear(space: oklch, oklch(0%, 0.104, 166deg), oklch(100%, 0.104, 166deg)),
  orange: gradient.linear(oklch(0%, 73%, 43deg), oklch(100%, 73%, 43deg)),
  amber: gradient.linear(space: oklch, oklch(0%, 50%, 48deg), oklch(70%, 70%, 58deg)),
)
#for (name, g) in thesis {
  assert.eq(ramps.at(name).stops(), g.stops(), message: name + " stops")
  assert.eq(ramps.at(name).space(), g.space(), message: name + " space")
  for t in range(0, 101, step: 5) {
    assert.eq(at(ramps.at(name), t * 1%), at(g, t * 1%), message: name + " at " + str(t))
  }
}

// 2. Ink tones sit on the 15% grid, and the named samples print what the
//    design system documents.
#for t in (stops.ink, stops.strong, stops.medium, stops.soft) { assert.eq(calc.rem(t / 1%, 15), 0) }
#for (job, t) in jobs { assert(t in (stops.strong, stops.medium, stops.soft), message: job) }
#assert.eq(hex(palette.primary), "#6a001a")
#assert.eq(hex(palette.secondary), "#922840")
#assert.eq(at(ramps.maroon, stops.soft), "#b7636c")
#assert.eq(roles.observed, ramps.blue.sample(stops.medium))
#assert.eq(roles.acted, ramps.rose.sample(stops.medium))
#assert.eq(roles.valued, ramps.teal.sample(stops.medium))

// Running text keeps 4.5:1 on paper: every ramp at medium and deeper, and
// every role color.
#let luminance(c) = {
  let (r, g, b, ..) = rgb(c).components(alpha: false).map(x => x / 100%)
  let lin(v) = if v <= 0.04045 { v / 12.92 } else { calc.pow((v + 0.055) / 1.055, 2.4) }
  0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
}
#let contrast(a, b) = {
  let (x, y) = (luminance(a), luminance(b))
  (calc.max(x, y) + 0.05) / (calc.min(x, y) + 0.05)
}
#for (name, g) in ramps {
  if name == "black" { continue }
  for t in (stops.ink, stops.strong, stops.medium) {
    assert(contrast(g.sample(t), white) >= 4.5, message: name + " at " + repr(t) + " is too light for text")
  }
}
#for (role, c) in roles { assert(contrast(c, white) >= 4.5, message: role) }
#for t in range(0, 101, step: 5) { assert(contrast(fulfillment.sample(t * 1%), white) >= 3, message: "fulfillment at " + str(t)) }

// 3. Quiet tones keep their sample's lightness and hue, and carry at most
//    `quietness × (1 − lightness)` of chroma, whatever the ramp.
#for (name, g) in ramps {
  for t in (stops.line, stops.rule, stops.fill) {
    let (l, c, h, ..) = oklch(quiet(g, t)).components()
    let (l0, c0, h0, ..) = oklch(g.sample(t)).components()
    assert.eq(l, l0, message: name)
    assert(c <= quietness * (1 - l / 100%) + 0.00001, message: name + " too loud at " + repr(t))
  }
}
#assert.eq(tones(ramps.rose).wash, quiet(ramps.rose, stops.fill))
#assert.eq(tones(ramps.rose).line, quiet(ramps.rose, stops.rule))
#assert.eq(palette.rule, quiet(ramps.maroon, stops.rule))

// 4. The classic tones are the dissertation's, value for value.
#let ct = classic-tones(ramps.maroon)
#assert.eq(hex(ct.wash), "#fff8f8")
#assert.eq(hex(ct.line), "#fce0e1")
#assert.eq(hex(ct.title), at(ramps.maroon, 35%))

// Chart slots alternate soft and medium.
#assert.eq(chart.len(), 6)

// 5. The fulfillment scale runs bad (dark crimson) to good (teal).
#assert.eq(hex(fulfillment.sample(0%)), hex(oklch(44%, 0.16, 14deg)))
#assert.eq(hex(fulfillment.sample(100%)), hex(oklch(58%, 0.11, 185deg)))
#assert.eq(fulfillment.space(), oklch)
#for t in range(0, 101, step: 5) {
  let l = oklch(fulfillment.sample(t * 1%)).components().at(0)
  assert(l <= 64%, message: "fulfillment too light at " + str(t))
}
#assert.eq(percent(0.424), "42%")
#assert.eq(state-of(0.4), "Problem")
#assert.eq(state-of(0.6), "Watch")
#assert.eq(state-of(0.9), "Fine")

// 6. Compliance mode only blackens: the headings sample a black ramp.
#let bu = thesis-style(colors: thesis-colors(compliance: "bu"))
#for l in bu.heading.levels { assert.eq(hex(l.text.fill), "#000000") }
#let identity = thesis-style()
#assert.eq(hex(identity.heading.levels.at(0).text.fill), "#6a001a")

// 7b. One color grows the whole identity: `ramp-from` gives back maroon and
//     sienna from their strong samples, and any color sits at 30%.
#for (name, shift) in (("maroon", 15deg), ("sienna", 10deg)) {
  let g = ramps.at(name)
  let r = ramp-from(g.sample(30%), hue-shift: shift)
  for t in range(0, 101, step: 10) { assert.eq(hex(r.sample(t * 1%)), hex(g.sample(t * 1%)), message: name) }
}
#for c in (rgb("#204060"), rgb("#7a3b12"), rgb("#1f6f5a")) { assert.eq(hex(ramp-from(c).sample(30%)), hex(c)) }

// 7. A ramp's mirror is its sample from the other end.
#assert.eq(mirror(30%), 70%)

// 8. The type scale is ×1.2 per step.
#assert.eq(scale(2, base: 10pt), 14.4pt)

// Everything also renders.
#note(title: [Note])[A note.]
#theorem(title: [Law])[A theorem.]
#algorithm(title: [Steps])[An algorithm.]
#notice[A notice.]
#pie(0.42) #price(none) #trace((0.2, 0.4, none, 0.6, 0.8), back: 2, ahead: 2)
#sep[a][b][c] #capsule-rule()
