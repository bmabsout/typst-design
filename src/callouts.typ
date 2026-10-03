// CALLOUTS — a rounded wash with a capsule outline, sampled from one ramp.
//
// Each kind owns a ramp: notes and definitions maroon, theorems rose,
// algorithms blue, warnings orange. Its five colours are the ramp's `tones`.

#import "color.typ": ramps, tones
#import "marks.typ": capsule

/// A titled block whose bottom edge fades out, so a callout that breaks
/// across a page reads as continuing. The title is kept with the content.
#let seamless-block(
  title: none,
  content,
  stroke: 1pt,
  fill: blue.lighten(80%),
  radius: 6pt,
  inset: 1em,
) = {
  let special_stroke = (
    ..stroke,
    paint: gradient.linear(stroke.paint.transparentize(100%), stroke.paint.transparentize(0%), stroke.paint.transparentize(0%), angle: 90deg).sharp(3),
  )
  let special_fill = gradient.linear(fill.transparentize(100%), fill.transparentize(0%), fill.transparentize(0%), angle: 90deg).sharp(3)
  let vertical-adjust = stroke.thickness / 2
  v(1.5em, weak: true)
  block(
    spacing: -2pt,
    sticky: true,
    radius: (top-left: radius, top-right: radius),
    stroke: (top: stroke, left: stroke, right: stroke),
    fill: fill,
    height: radius * 2 + 1em,
    width: 100%,
    inset: inset,
    v(0.5em) + title,
  )
  block(
    spacing: -2pt,
    stroke: (left: stroke, right: stroke),
    fill: fill,
    inset: inset,
    width: 100%,
    outset: (top: -vertical-adjust, bottom: -vertical-adjust),
    breakable: true,
    content,
  )
  v(-1em)
  block(
    spacing: -2pt,
    radius: (bottom-left: radius, bottom-right: radius),
    stroke: (bottom: special_stroke, left: special_stroke, right: special_stroke),
    outset: (top: 0em),
    fill: special_fill,
    width: 100%,
    height: radius * 2,
  )
  v(1.5em, weak: true)
}

/// Builds the callout family. Every argument has the identity's default; a
/// document passes what differs (the thesis fixes `title-size` to the size
/// its notes were first set at).
///
/// - `title-size`: the title's size, bold italic in the ramp's title tone.
/// - `figure`: wrap each callout in a `figure` of its `kind`, so it can be
///   labelled and referenced (`@thm:x`). Off for documents with no figures.
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
) = {
  let wrap(body, kind, supplement, g) = if figure {
    std.figure(body, kind: kind, supplement: text(fill: tones(g).supplement, supplement))
  } else { body }

  let note(content, gradient: note-ramp, title: none, engine: seamless-block, kind: "note", supplement: [Note]) = wrap(align(center, {
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

#let _default = callouts()
#let note = _default.note
#let theorem = _default.theorem
#let algorithm = _default.algorithm
#let notice = _default.notice
