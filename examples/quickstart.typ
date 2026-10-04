#import "../lib.typ": *
#show: callout-rules

#set page(width: 16cm, height: auto, margin: 1.2cm)
#set text(font: faces.serif, size: 10.5pt, fill: palette.ink)
#set par(justify: true)

#text(font: faces.display, size: scale(4), weight: 600, fill: palette.primary)[A note on fulfillment]
#capsule-rule()

Every color here is a sample of a ramp#diamond()structure comes from a capsule rule and a diamond#diamond()callouts take one ramp each.

#note(title: [Definition])[
  A *fulfillment* is a value in $[0, 1]$ saying how well a requirement is met: #price(0.18) is urgent, #price(0.86) is fine.
]

#theorem(title: [Monotonicity])[
  Raising any one fulfillment while holding the others fixed never lowers their composition.
]
