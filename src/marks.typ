// MARKS — structure comes from two marks and space, never from boxes.
//
// The capsule rule divides: a thick dotted line with round caps, so each dot
// reads as a short capsule. The diamond joins: the only inline separator.

#import "color.typ": palette, ramps, stops

/// The capsule stroke: round-capped dots `period` apart. Use it anywhere a
/// stroke is accepted (a line, a callout's outline, a table rule).
#let capsule(paint, thickness: 3pt, period: 6pt) = (
  paint: paint,
  thickness: thickness,
  dash: ("dot", period),
  cap: "round",
)

/// A full-width capsule rule. The default paint is the identity's `rule`
/// tone; the thesis and the CV each pass the tone their pages were set in.
#let capsule-rule(paint: palette.rule, thickness: 3pt, period: 6pt, length: 100%) = line(
  length: length,
  stroke: capsule(paint, thickness: thickness, period: period),
)

/// The diamond: a square of `size` turned 45°, rounded at `radius`, filled
/// and outlined in the blush, raised a tenth of an em, with `spacing` either
/// side. It scales with the text.
#let diamond(
  spacing: 0.4em,
  size: 0.4em,
  radius: 0.15em,
  fill: palette.mark-fill,
  stroke: 0.1em + palette.mark-line,
) = {
  h(spacing)
  box(baseline: -10%, rotate(45deg, rect(width: size, height: size, radius: radius, fill: fill, stroke: stroke)))
  h(spacing)
}

/// Items joined by diamonds: `#sep[a][b][c]`.
#let sep(..items, diamond: diamond) = items.pos().join(diamond())
