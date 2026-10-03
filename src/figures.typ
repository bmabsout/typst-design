// FIGURES — CeTZ primitives for the thesis's diagrams: a distribution drawn
// as a bell with hatching under it, and a value range as a segment with a
// tick. They take the `cetz` module as their first argument, so this
// library depends on no package and a document brings the CeTZ it uses:
//
//   #import "@preview/cetz:0.3.4"
//   #let (bell, segment) = (figures.bell.with(cetz), figures.segment.with(cetz))

#let figure-style = (
  stroke: 0.8pt,
  thin: 0.2pt,
  delim: 0.15,
  space: 2,
)

/// A distribution: a bell outline with thin verticals filling under it.
#let bell(cetz, pos, color: black, name: "bell", style: figure-style) = {
  import cetz.draw: *
  group(name: name, ctx => {
    let (_, pos) = cetz.coordinate.resolve(ctx, pos)
    let (x, y, z) = pos
    let curve(t) = 0.6 * calc.exp(-7 * t * t)
    for i in range(40) {
      let t1 = -style.space / 2 + style.space * i / 40
      let t2 = -style.space / 2 + style.space * (i + 1) / 40
      line((t1 + x, y + curve(t1)), (t2 + x, y + curve(t2)), stroke: (thickness: style.stroke, paint: color))
      line((t1 + x, y), (t1 + x, y + curve(t1)), stroke: (thickness: style.thin, paint: color))
    }
  })
}

/// A range: a segment with end ticks and a dot at `tick_pos`, anchored as
/// `<name>.tick`.
#let segment(cetz, pos, tick_pos: 0.5, color: black, name: "segment", style: figure-style) = {
  import cetz.draw: *
  group(name: name, ctx => {
    let (_, pos) = cetz.coordinate.resolve(ctx, pos)
    let (x, y, z) = pos
    set-style(stroke: (paint: color, cap: "round", thickness: style.stroke))
    line((x, y), (x + style.space, y))
    line((x, y - style.delim), (x, y + style.delim))
    line((x + style.space, y - style.delim), (x + style.space, y + style.delim))
    circle((x + style.space * tick_pos, y), radius: 0.07, fill: color, name: "tick", stroke: none)
  })
}
