// A look of one's own: a theme names what differs, and the kit draws in it.
#import "../lib.typ": *

#let look = theme(
  identity: rgb("#1f4e79"),           // one color grows the identity ramp
  paper: oklch(97.5%, 0.008, 75deg),  // text deepens until it reads on it
  callouts: (theorem: ramps.gold),
)
#let (palette, capsule-rule, diamond, note, theorem, ..) = themed(look)

#show: callout-rules
#set page(width: 16cm, height: auto, margin: 1.2cm, fill: palette.paper)
#set text(font: faces.serif, size: 10.5pt, fill: palette.ink)

#text(font: faces.display, size: scale(4), weight: 600, fill: palette.primary)[A look of its own]
#capsule-rule()

The same rules place every color#diamond()only the identity, the paper and one callout ramp changed.

#note(title: [Definition])[A note takes the identity ramp.]
#theorem(title: [A gold theorem])[A theorem takes the ramp the theme names.]
