// FRAMES: a page-spanning callout drawn on the page's background.
//
// The block itself draws nothing. It records where it starts and where it
// ends, and `frame-rules` draws, on every page the block touches, one shape
// with the block's fill and stroke: rounded where the block really starts or
// ends, open where a page cuts it. Each page's shape is one path, so a dashed
// stroke runs on around the corners without a seam.
//
// The cost: the document must `#show: frame-rules`, which sets the page
// background (pass your own as `background:` to keep it), and a frame on a
// continued page spans the page's whole text area, from margin to margin.

#let _mark = <typst-design-frame>
#let _frames = counter("typst-design-frame")

/// The body area's top and bottom on the current page, from its margins.
#let _body-edges() = {
  let m = page.margin
  let auto-margin = 2.5 / 21 * calc.min(page.width, page.height)
  let side(name) = {
    let v = if type(m) == dictionary {
      m.at(name, default: m.at("y", default: m.at("rest", default: auto)))
    } else { m }
    if v == auto { auto-margin } else if type(v) == relative { v.length + v.ratio * page.height } else if type(v) == ratio { v * page.height } else { v }
  }
  (top: side("top").to-absolute(), bottom: page.height - side("bottom").to-absolute())
}

/// A rounded block that breaks across pages, drawn by `frame-rules`.
#let frame(
  title: none,
  content,
  stroke: 1pt,
  fill: none,
  radius: 6pt,
  inset: 1em,
  spacing: 1.5em,
  title-gap: 1em,
) = {
  _frames.step()
  context {
    let id = _frames.get().first()
    let pad = inset.to-absolute()
    let style = (stroke: stroke, fill: fill, radius: radius.to-absolute(), inset: pad)
    let mark(kind) = place(layout(size => context [#metadata((
      id: id,
      kind: kind,
      position: here().position(),
      width: size.width,
      ..style,
    ))#_mark]))
    v(spacing, weak: true)
    block(breakable: true, width: 100%, inset: (x: pad, y: 0pt), spacing: 0pt, {
      // The start mark, the padding and the title stick to the first line,
      // so a frame never starts on a page it has no text on.
      block(sticky: true, spacing: 0pt, width: 100%, {
        mark("start")
        v(pad)
        if title != none {
          title
          v(title-gap)
        }
      })
      content
      v(pad)
      mark("end")
    })
    v(spacing, weak: true)
  }
}

/// Draws every frame's piece on the current page. Use as a page background,
/// or let `frame-rules` install it.
#let frame-layer() = context {
  let p = here().page()
  let marks = query(_mark).map(m => m.value)
  let ends = (:)
  for m in marks { if m.kind == "end" { ends.insert(str(m.id), m) } }
  let body = _body-edges()
  for s in marks.filter(m => m.kind == "start") {
    let e = ends.at(str(s.id), default: none)
    if e == none { continue }
    let (first, last) = (s.position.page, e.position.page)
    if p < first or p > last { continue }
    let opens = p == first
    let closes = p == last
    let y0 = if opens { s.position.y } else { body.top }
    let y1 = if closes { e.position.y } else { body.bottom }
    let r = s.radius
    place(top + left, dx: s.position.x - s.inset, dy: y0, rect(
      width: s.width + 2 * s.inset,
      height: y1 - y0,
      fill: s.fill,
      stroke: (
        left: s.stroke,
        right: s.stroke,
        top: if opens { s.stroke } else { none },
        bottom: if closes { s.stroke } else { none },
      ),
      radius: (
        top-left: if opens { r } else { 0pt },
        top-right: if opens { r } else { 0pt },
        bottom-left: if closes { r } else { 0pt },
        bottom-right: if closes { r } else { 0pt },
      ),
    ))
  }
}

/// The document rule frames need: `#show: frame-rules`. A page background
/// of your own goes in `background` and is drawn under the frames.
#let frame-rules(body, background: none) = {
  set page(background: {
    background
    frame-layer()
  })
  body
}
