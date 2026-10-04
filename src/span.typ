// SPAN: a stretch of the flow that marks where it really starts and ends.
//
// A page break is not a boundary. A span may break across pages, and only
// its real start and its real end carry marks: a rule and a title, a
// callout's rounded caps. Spans that follow one another can share a
// boundary, so two marks that would meet become one.
//
//   span(open: rule + title, close: rule, merge: "section")[..]
//
// - The opening mark is kept with the first line, so it never stands alone
//   at the foot of a page.
// - The closing mark is placed: it takes no room, so drawing it or not
//   cannot move the layout it was measured from.
// - With `merge`, the closing mark is drawn only when the next span with the
//   same key starts on another page, or there is none.
//
// The other style marks every page instead: `edge` is a stroke drawn as the
// top and bottom of each page piece, so a page always starts and ends on
// it, and spans set edge to edge share one.

/// A span's start, carrying its merge key.
#let span-start = <typst-design-span>

/// A closing mark that was drawn, carrying its merge key. Tests count these.
#let span-end = <typst-design-span-end>

/// A stretch of the flow with marks at its real start and end.
///
/// - `open`: content set before the body and kept with its first line. It
///   takes room.
/// - `close`: content placed after the body. It takes no room. `close-at`
///   is passed to `place` (`dx`, `dy`) to position it from the end of the
///   body.
/// - `merge`: a key. Spans sharing it share a boundary with the next one:
///   the close is drawn only when that span starts on another page.
/// - `edge`: a stroke drawn as the top and bottom of every page piece, for
///   marks that belong to pages rather than to boundaries. Set spans with
///   `spacing: 0pt` so neighbors share an edge.
/// - `region`: the block the body sits in (fill, side strokes, inset,
///   width), drawn on every page the span crosses.
#let span(
  body,
  open: none,
  close: none,
  close-at: (:),
  merge: none,
  edge: none,
  ..region,
) = {
  let region = region.named()
  if edge != none {
    let stroke = region.at("stroke", default: (:))
    let stroke = if type(stroke) == dictionary { stroke } else if stroke == none { (:) } else { (x: stroke) }
    region.insert("stroke", stroke + (top: edge, bottom: edge))
  }
  block(breakable: true, ..region, {
    block(sticky: true, breakable: false, spacing: 0pt, width: 100%, {
      [#metadata(merge)<typst-design-span>]
      open
    })
    body
    if close != none {
      let mark = place(..close-at, close) + [#metadata(merge)<typst-design-span-end>]
      if merge == none { mark } else {
        context {
          let next = query(selector(span-start).after(here())).filter(m => m.value == merge)
          if next == () or next.first().location().page() != here().page() { mark }
        }
      }
    }
  })
}
