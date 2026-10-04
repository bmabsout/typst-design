// FPL MARKS: a fulfillment in [0, 1] drawn as color, a pie and a trace.
//
// The marks of Prodrome's Typst package (`prodrome/typst/lib.typ`), drawn
// in the identity's own bad-to-good scale
// (`fulfillment` in color.typ). These marks compute nothing about
// fulfillment: every number they draw was answered elsewhere. Low is urgent.

#import "color.typ": fulfillment

/// The color of a value in [0, 1]: a sample of the one scale.
#let fulfillment-color(value) = fulfillment.sample(value * 100%)

/// The scale laid bottom (0) to top (1) over its container, so a stroke in a
/// box whose height is the 0–100% range is `fulfillment-color(v)` at its own height.
#let upward(alpha: 100%) = gradient.linear(
  ..fulfillment.stops().map(((c, at)) => (c.transparentize(100% - alpha), at)),
  space: fulfillment.space(),
  dir: btt,
  relative: "parent",
)

/// No value at all is not a zero, so it is never a color of the scale.
#let unpriced = luma(155)
#let ink = luma(34)

/// The words for a value: "Problem" below 0.5, "Watch" below 0.7, "Fine"
/// from there, "Unpriced" for none. Words only. The color is `fulfillment-color`'s.
#let state-of(value) = if value == none or value == "absent" { "Unpriced" } else if value < 0.5 {
  "Problem"
} else if value < 0.7 { "Watch" } else { "Fine" }

/// `0.42` as `42%`, `∅` for absent, `–` for none.
#let percent(value) = if value == "absent" { "∅" } else if value == none { "–" } else {
  str(int(calc.round(value * 100))) + "%"
}

/// Drawn content: itself on a page, an inline SVG in HTML.
// `target` and `html` exist only when HTML export is enabled.
#let _html = "target" in dictionary(std)
#let _frame(body) = if _html { context if std.target() == "html" { box(std.html.frame(body)) } else { body } } else { body }

/// THE PIE: a value's share of a disc from twelve o'clock clockwise, on a
/// faint track of its own color, outlined thin in it. Sized in `em` so it
/// sits beside text at any size.
#let pie(value, size: 0.82em, edge: 6.7%) = context {
  let size = size.to-absolute()
  let c = fulfillment-color(value)
  let r = size / 2
  let edge = size * (edge / 100%)
  let at(angle) = (r + r * calc.sin(angle), r - r * calc.cos(angle))
  // One vertex every 5°, so the arc stays round at any size.
  let steps = calc.max(1, calc.ceil(value * 72))
  _frame(box(width: size, height: size, baseline: 12%, {
    place(circle(radius: r, fill: c.transparentize(78%)))
    if value >= 1 {
      place(circle(radius: r, fill: c))
    } else if value > 0 {
      place(polygon(fill: c, (r, r), ..range(steps + 1).map(i => at(360deg * value * i / steps))))
    }
    place(dx: edge / 2, dy: edge / 2, circle(radius: r - edge / 2, stroke: edge + c))
  }))
}

/// A value as a list shows it: its pie and its percentage, or "unpriced".
#let price(value) = if value == none or value == "absent" {
  text(fill: unpriced)[unpriced]
} else [#pie(value)~#text(fill: ink, strong(percent(value)))]

#let _runs(points) = {
  let runs = ((),)
  for point in points {
    if point.at(1) == none {
      if runs.last().len() > 0 { runs.push(()) }
    } else { runs.last().push(point) }
  }
  runs.filter(run => run.len() > 0)
}

/// THE TRACE: a value over the days around now, one thick line colored at
/// every point by its own value, in a 0–100% frame with a dashed half. The
/// past is faded, and now is a thin ink line and a dot. `values` are evenly
/// spaced from `back` days before now to `ahead` days after, `none` a gap.
/// Every inner length is a share of `height`, so the mark scales whole.
#let trace(values, at: none, back: 15, ahead: 15, width: 25em, height: 9.8em) = context {
  let (width, height) = (width.to-absolute(), height.to-absolute())
  let u = height / 108 // the unit the mark was drawn in
  let faint = luma(205)
  let quiet = luma(125)
  let n = values.len()
  let now = int(calc.round((n - 1) * back / (back + ahead)))
  let gutter = 16 * u
  let (top, margin, foot) = (4 * u, 18 * u, 16 * u)
  let (w, h) = (width - gutter - margin, height - top - foot)
  let point((i, value)) = (w * i / (n - 1), h * (1 - value))
  let thick = 3 * u
  let line-of(run, paint) = if run.len() == 1 {
    let (x, y) = point(run.first())
    place(dx: x - thick / 2, dy: y - thick / 2, circle(radius: thick / 2, fill: fulfillment-color(run.first().at(1))))
  } else {
    place(curve(
      stroke: (paint: paint, thickness: thick, cap: "round", join: "round"),
      curve.move(point(run.first())),
      ..run.slice(1).map(p => curve.line(point(p))),
    ))
  }
  let indexed = values.enumerate()
  let label(body, fill: quiet) = text(size: 6.5 * u, fill: fill, body)
  let x-of(day) = gutter + w * (day + back) / (back + ahead)
  let date(day) = if at == none { [] } else { (at + duration(days: day)).display("[month repr:short] [day padding:none]") }
  _frame(box(width: width, height: height, {
    place(dx: gutter, dy: top, rect(width: w, height: h, stroke: 0.5 * u + faint))
    place(dx: gutter, dy: top + h / 2, line(length: w, stroke: (paint: faint, thickness: 0.5 * u, dash: "dashed")))
    for (level, name) in ((1, "100"), (0.5, "50"), (0, "0")) {
      place(dy: top + h * (1 - level) - 4 * u, box(width: gutter - 3 * u, height: 8 * u, align(right + horizon, label(name))))
    }
    place(dx: gutter, dy: top, box(width: w, height: h, {
      for run in _runs(indexed.slice(0, now + 1)) { line-of(run, upward(alpha: 35%)) }
      for run in _runs(indexed.slice(now)) { line-of(run, upward()) }
    }))
    let x = x-of(0)
    place(dx: x - 0.35 * u, dy: top, rect(width: 0.7 * u, height: h, fill: ink))
    let v = values.at(now)
    if v != none {
      let r = 3.2 * u
      place(dx: x - r, dy: top + h * (1 - v) - r, circle(radius: r, fill: fulfillment-color(v), stroke: 0.8 * u + white))
    }
    let dy = top + h + 4 * u
    let cell = 40 * u
    place(dx: gutter, dy: dy, label(date(-back)))
    place(dx: gutter + w - cell, dy: dy, box(width: cell, align(right, label(date(ahead)))))
    for day in (-7, 7).filter(day => -back < day and day < ahead) {
      place(dx: x-of(day) - cell / 2, dy: dy, box(width: cell, align(center, label(date(day)))))
    }
    place(dx: x - cell / 2, dy: dy, box(width: cell, align(center, label(fill: ink, strong(date(0))))))
  }))
}
