// DOCUMENT: a plain working document (notes, lists, reports) in the CV's
// voice: a serif body, sans capitals over a capsule rule for sections, one
// accent for titles, links and ornaments.

#import "../color.typ": palette, as-text
#import "../type.typ": faces
#import "../marks.typ": capsule-rule, diamond

#let doc-fonts = (
  body: ("EB Garamond", "EB Garamond 12", "Libertinus Serif"),
  sans: ("Libertinus Sans", "Libertinus Serif"),
  mono: ("Libertinus Mono", "DejaVu Sans Mono"),
)

/// The rule a section title stands on.
#let doc-rule = capsule-rule(paint: palette.rule)

/// A section title not tied to a heading: sans capitals in the accent.
#let section-title(body, size: 13pt, fill: palette.primary, font: doc-fonts.sans) = {
  text(font: font, size: size, weight: "bold", fill: fill, tracking: 0.04em, upper(body))
  v(0.15em)
  doc-rule
}

/// A blush panel: the CV's contact box, a card.
#let panel(body, inset: 1em, radius: 0.35em) = block(
  fill: palette.mark-fill,
  stroke: 0.6pt + palette.mark-line,
  radius: radius,
  inset: inset,
  width: 100%,
  body,
)

/// A line with its date (or other minor label) set right in small caps.
#let dated(body, date) = grid(
  columns: (1fr, auto),
  align: (left + bottom, right + bottom),
  body,
  text(size: 0.85em, smallcaps(lower(date))),
)

/// An emphasized phrase in the accent.
#let accent(body) = text(fill: palette.primary, style: "italic", body)

/// The show rule: `#show: document.with(title: [..])`.
///   level 1  the document's title: large serif in the accent, a rule under.
///   level 2  a section: sans capitals over the rule.
///   level 3  a subsection: sans, medium, the secondary.
#let document(body, size: 11pt, title: none, fonts: doc-fonts, paper: "a4", ink: oklch(19.77%, 0.007, 17.5deg)) = {
  let primary = palette.primary
  set text(font: fonts.body, size: size, fill: ink, lang: "en")
  set par(leading: 0.7em, spacing: 1em, justify: false)
  set page(
    paper: paper,
    margin: (x: 1.1in, top: 1in, bottom: 1in),
    numbering: "1",
    number-align: center,
    footer: context align(center, text(fill: primary, size: 12pt, counter(page).display("1"))),
  )
  set list(marker: diamond(spacing: 0em), spacing: 0.55em)
  set enum(numbering: n => text(fill: primary, numbering("1.", n)))
  show emph: set text(fill: palette.secondary)
  show raw: set text(font: fonts.mono, size: 0.9em)
  show strong: set text(fill: ink)
  // A link out is underlined in the accent. A link within the document reads
  // as the text it is.
  show link: it => if type(it.dest) == str { text(fill: as-text(primary), underline(it)) } else { it }
  show heading.where(level: 1): it => block(above: 1.5em, below: 1.2em, sticky: true, {
    text(font: fonts.body, size: 2em, weight: "regular", fill: primary, it.body)
    v(0.2em)
    doc-rule
  })
  show heading.where(level: 2): it => block(above: 1.6em, below: 0.9em, sticky: true, section-title(it.body, font: fonts.sans))
  show heading.where(level: 3): it => block(above: 1.1em, below: 0.6em, sticky: true, text(font: fonts.sans, size: 13pt, weight: "medium", fill: palette.secondary, it.body))
  if title != none { heading(level: 1, title) }
  body
}
