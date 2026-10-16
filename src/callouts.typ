// CALLOUTS: a rounded wash with a capsule outline, sampled from one ramp.
//
// Each kind owns a ramp: notes and definitions maroon, theorems rose,
// algorithms blue, warnings orange. Its five colors are the ramp's `tones`.

#import "color.typ": ramps, tones as _tones
#import "marks.typ": capsule
#import "span.typ": span

/// A rounded block that breaks across pages the way a long callout should:
/// rounded only at its real top and bottom, and simply open where a page
/// cuts it. Typst rounds and closes every fragment of a breakable block, so
/// the block itself carries only its side strokes and fill, and the two
/// rounded caps are placed in the flow: the top one above its first
/// fragment, the bottom one after its last line, wherever that falls.
#let flow-block(
  title: none,
  content,
  stroke: 1pt,
  fill: none,
  radius: 6pt,
  inset: 1em,
  spacing: 1.5em,
  title-gap: 1em,
  breathe: 0.5em,
) = context {
  let cap(top) = block(
    width: 100%,
    height: radius,
    above: 0pt,
    below: 0pt,
    fill: fill,
    radius: if top { (top: radius) } else { (bottom: radius) },
    stroke: if top { (top: stroke, x: stroke) } else { (bottom: stroke, x: stroke) },
  )
  // Text sits `inset + breathe` from the rounded edges, and the caps
  // already give `radius` of that.
  let pad = calc.max((inset + breathe).to-absolute() - radius, 0.3em.to-absolute())
  // Spacing outside the caps: `above`/`below` would vanish at the start of
  // a container (a figure, a grid cell), so the gap is padding.
  v(spacing, weak: true)
  // A span whose region is the wash and the side strokes, and whose marks
  // are the rounded caps: the top cap opens it, the bottom cap closes it,
  // and a page cut is simply open.
  let cap-box(top) = box(width: 100% + 2 * inset, cap(top))
  std.pad(top: radius, bottom: radius, span(
    width: 100%,
    fill: fill,
    stroke: (x: stroke),
    inset: (x: inset, y: 0pt),
    spacing: 0pt,
    open: {
      place(dx: -inset, dy: -radius, cap-box(true))
      v(pad)
      if title != none {
        title
        v(title-gap)
      }
    },
    close: cap-box(false),
    close-at: (dx: -inset),
    {
      content
      v(pad)
    },
  ))
  v(spacing, weak: true)
}

/// Builds the callout family. Every argument has the identity's default, and
/// a document passes what differs (the thesis fixes `title-size` to the size
/// its notes were first set at).
///
/// - `title-size`: the title's size, bold italic in the ramp's title tone.
/// - `figure`: wrap each callout in a `figure` of its `kind`, so it can be
///   labeled and referenced (`@thm:x`). Off for documents with no figures.
/// - `engine`: override the block a titled callout is drawn with.
/// - `tones`: override the colors a callout takes from its ramp: a function
///   from a ramp to `(wash, line, title, supplement, ink, notice)`.
#let callouts(
  title-size: 1.2em,
  radius: 12pt,
  inset: 1em,
  outline: 3pt,
  period: 6pt,
  note-ramp: ramps.maroon,
  theorem-ramp: ramps.rose,
  algorithm-ramp: ramps.blue,
  notice-ramp: ramps.orange,
  figure: true,
  engine: flow-block,
  tones: _tones,
) = {
  let wrap(body, kind, supplement, g) = if figure {
    std.figure(body, kind: kind, supplement: text(fill: tones(g).supplement, supplement))
  } else { body }

  let note(content, gradient: note-ramp, title: none, engine: engine, kind: "note", supplement: [Note]) = wrap(align(center, {
    let t = tones(gradient)
    if title != none {
      engine = engine.with(title: {
        show text: it => text(size: title-size, weight: "bold", style: "italic", fill: t.title, it)
        title
      })
    }
    [
      #engine(
        stroke: capsule(t.line, thickness: outline, period: period),
        radius: radius,
        fill: t.wash,
        inset: inset,
        align(left, [
          #set text(fill: t.ink)
          #content
        ]),
      )

    ]
  }), kind, supplement, gradient)

  let numbered(name, kind, supplement, g) = (title: none, body, gradient: g) => {
    let c = counter(kind)
    let title = [#name #context {
      c.step()
      [#(c.get().first() + 1)]
    }: #title]
    note(gradient: gradient, title: title, kind: kind, supplement: supplement)[
      #body
    ]
  }

  (
    note: note,
    theorem: numbered([Theorem], "theorem", [Theorem], theorem-ramp),
    algorithm: numbered([ Algorithm], "algorithm", [Algorithm], algorithm-ramp),
    notice: (content, gradient: notice-ramp) => note(
      [#text(fill: tones(gradient).notice)[_*Notice:*_] #content],
      gradient: gradient,
      engine: block,
    ),
  )
}

/// The document rule callouts need: `#show: callout-rules`. A figure is
/// unbreakable by default, which would push a long callout whole onto the
/// next page. This lets the callout kinds break like their blocks do. (It
/// lives at the document level so a callout stays a figure you can label.)
#let callout-rules(body, kinds: ("note", "theorem", "algorithm")) = {
  show std.figure: it => if it.kind in kinds { set block(breakable: true); it } else { it }
  body
}

#let _default = callouts()
#let note = _default.note
#let theorem = _default.theorem
#let algorithm = _default.algorithm
#let notice = _default.notice
