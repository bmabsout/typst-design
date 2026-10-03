// The design system's laws. Compiling this file is the test: every
// `assert` must hold. Run: typst compile --root . tests/laws.typ /tmp/laws.pdf
#import "../lib.typ": *

#let hex(c) = c.to-hex()
#let at(g, t) = hex(g.sample(t))

// 1. The ramps are the thesis's gradients, stop for stop. These literals are
//    the definitions in bmabsout/Thesis src/style.typ; a ramp that drifts
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

// 2. The named samples print the values the design system documents.
#assert.eq(hex(palette.primary), "#6a001a")
#assert.eq(at(ramps.maroon, 45%), "#922840")
#assert.eq(at(ramps.maroon, 60%), "#b7636c")
#assert.eq(hex(palette.rule), "#f9d4d3")
#assert.eq(hex(roles.observed), "#4172b4")
#assert.eq(hex(roles.acted), "#a35081")
#assert.eq(hex(roles.valued), "#1f8463")
#assert.eq(chart.map(hex), ("#588bce", "#8d3c6c", "#3f9d7b", "#9c3a00", "#694b96", "#856801"))

// 3. Callout tones are the note's derivation from a ramp.
#let t = tones(ramps.maroon)
#assert.eq(hex(t.wash), "#fff8f8")
#assert.eq(hex(t.line), "#fce0e1")
#assert.eq(hex(t.title), at(ramps.maroon, 35%))

// 4. A shade keeps its ramp's lightness and hue, and scales only chroma.
#let s = oklch(shade(ramps.maroon, 82%, chroma: 50%)).components()
#let r = oklch(ramps.maroon.sample(82%)).components()
#assert.eq(s.at(0), r.at(0))
#assert.eq(s.at(2), r.at(2))
#assert(calc.abs(s.at(1) - r.at(1) / 2) < 0.0001)

// 5. The fulfillment scale runs bad (dark crimson) to good (teal), and every
//    sample is dark enough to colour text on paper.
#assert.eq(hex(fulfillment.sample(0%)), hex(oklch(44%, 0.16, 14deg)))
#assert.eq(hex(fulfillment.sample(100%)), hex(oklch(58%, 0.11, 185deg)))
#assert.eq(fulfillment.space(), oklch)
#for t in range(0, 101, step: 5) {
  let l = oklch(fulfillment.sample(t * 1%)).components().at(0)
  assert(l <= 70%, message: "fulfillment too light at " + str(t))
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
