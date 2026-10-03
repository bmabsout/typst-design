// CV — the curriculum vitae's building blocks: sections over capsule rules,
// entries with a date flush right, labelled links joined by diamonds,
// publications and a blush contact panel.
//
// `cv-kit(style)` returns every block configured by one style dictionary;
// `cv-style(..)` builds that dictionary from the identity's defaults, so a
// document overrides only what differs.

#import "../color.typ": palette, ramps, shade as _shade, stops
#import "../type.typ": faces
#import "../marks.typ": capsule-rule, diamond as _diamond
#import "../icons.typ": fa

/// The CV's style. Colours are the identity's ramp samples; faces default to
/// the CV family (EB Garamond, Libertinus Sans labels).
#let cv-style(
  ramp: ramps.maroon,
  primary: auto,
  secondary: auto,
  shade: auto,
  shade-line: auto,
  rule: auto,
  body: faces.garamond,
  sans: faces.libertinus-sans,
  icons: faces.icons,
  owner: none,
) = {
  // Every colour is a sample (or a quiet shade) of one ramp; pass `ramp` to
  // recolour the whole CV, or a single colour to override it.
  let pick(v, d) = if v == auto { d } else { v }
  let primary = pick(primary, ramp.sample(stops.heading-1))
  let secondary = pick(secondary, ramp.sample(stops.heading-2))
  let shade-fill = pick(shade, _shade(ramp, 97%, chroma: 35%))
  let shade-line = pick(shade-line, _shade(ramp, 82%, chroma: 80%))
  let rule = pick(rule, _shade(ramp, 91%, chroma: 55%))
  (
  colors: (
    primary: primary,
    secondary: secondary,
    shade: shade-fill,
    shade-fg: primary,
    shade-line: shade-line,
    rule: rule,
  ),
  fonts: (body: body, sans: sans, icons: icons),
  spacing: (
    section: 1.2em, // between sections
    element: 1em, // between entries
    paragraph: 0.6em, // between lines in an entry
  ),
  insets: (
    section: (left: 1.2em, top: 1.2em),
    inner: (left: 1em, top: 0.8em),
  ),
  header: (
    name: (font: sans, size: 28pt, weight: "medium"),
    contact: (
      text: (size: 12pt),
      icon: (size: 12pt, width: 1.6em),
      box: (gutter: 0.8em, inset: 12pt, radius: 4pt),
    ),
    vertical_padding: 2em,
  ),
  section: (fill: primary, font: sans, size: 13pt, weight: "bold"),
  subsection: (fill: secondary, font: sans, size: 13pt, weight: "medium"),
  entry: (size: 11pt, heading: (weight: "bold")),
  owner: owner,
  )
}

#let cv-kit(style) = {
  let diamond = _diamond.with(fill: style.colors.shade, stroke: 0.1em + style.colors.shade-line)
  let rule = capsule-rule(paint: style.colors.rule)

  /// "label: content", the label semibold.
  let labeled(label, content) = [#text(weight: 600)[#label:] #content]
  let emphasis(content) = text(style: "italic", weight: "medium")[#content]
  /// A line of labelled links under an entry, joined by diamonds.
  let links(..items) = [\ #h(-style.insets.inner.left / 2)#items.pos().join([#diamond()])]

  /// A title kept with its first item; the rest may break.
  let titled-list(title, items, inset, spacing) = {
    set block(spacing: 0em)
    block(breakable: false)[
      #title
      #if items != () {
        pad(..inset)[#items.at(0)]
      }
    ]
    if items.len() > 1 {
      v(spacing)
      pad(left: inset.left, stack(spacing: spacing, ..items.slice(1)))
    }
  }

  let titled-block(title, content, inset: none) = {
    set block(spacing: 0em, breakable: false)
    set par(leading: 0em)
    stack(spacing: 0em, title, block(inset: inset, content))
  }

  /// The first child stays with `first`, the last with `last`; the middle
  /// may break.
  let stack-unbreakable(first, last, spacing, inset, children) = if children.len() == 1 {
    block(breakable: false)[#first#block(inset: inset)[#children.first()]#last]
  } else {
    block(breakable: true, sticky: true)[#first#block(inset: inset)[#children.first()]]
    v(spacing, weak: true)
    children.slice(1, -1).map(child => block(inset: (left: inset.left))[#child]).intersperse(v(spacing, weak: true)).reduce((x, y) => x + y)
    v(spacing, weak: true)
    block(breakable: false)[#block(inset: (left: inset.left))[#children.last()]#last]
  }

  /// A section: a capsule rule, the UPPERCASE title, the items, a rule.
  let section-list(title, items) = stack-unbreakable(
    {
      rule
      v(style.spacing.section)
      text(..style.section, upper(title))
    },
    v(style.spacing.section) + rule,
    style.spacing.section,
    style.insets.section,
    items,
  )

  let sections(..sections) = {
    (..sections.pos()).reduce((x, y) => x + y)
    v(100fr)
  }

  let subsection(subsection) = titled-block(
    text(font: style.subsection.font, size: style.subsection.size, weight: style.subsection.weight, fill: style.subsection.fill)[#subsection.title],
    block(breakable: true)[
      #subsection.body
    ],
    inset: style.insets.inner,
  )

  let subsections-list(title, subsections) = titled-list(text(..style.subsection, title), subsections, style.insets.inner, style.spacing.element)

  /// An entry's heading row: bold title, italic organisation, the date flush
  /// right in small caps.
  let entry-heading(l: none, m: none, r: none) = {
    text(weight: style.entry.heading.weight, l)
    h(0.5em)
    text(style: "italic", m)
    h(1fr)
    smallcaps(lower(r))
  }

  let entry(heading, body) = {
    set text(size: style.entry.size, font: style.fonts.body)
    titled-block(
      heading,
      par(leading: style.spacing.paragraph)[
        #body
      ],
      inset: if body != [] { style.insets.inner } else { (left: 0em, top: 0em) },
    )
  }

  let entries(entries) = stack(spacing: style.spacing.element, ..entries.map(entry => block(breakable: false, entry)))

  let review-venue-entry(name, papers) = {
    name
    metadata(papers)
  }
  let review-venues(venues) = venues.join([#diamond()])

  /// Authors joined by diamonds; a name containing `style.owner` in bold.
  let authors(names) = names.split(" and ").map(name => if style.owner != none and name.contains(style.owner) [*#name*] else { name }).join([#diamond()])

  /// A publication: its number, the authors with the year (and citations)
  /// flush right, then the italic title and labelled links.
  let publication-entry(publication, label) = grid(
    columns: (auto, 1fr),
    gutter: 1em,
    [#label],
    block(breakable: false, stack(
      spacing: style.spacing.paragraph,
      [
        #authors(publication.authors)
        #h(1fr)
        #smallcaps([#(if (publication.at("citations", default: 0) != 0) [#smallcaps[(citations: #publication.citations) ]])#publication.year])
      ],
      [
        #block(inset: (left: style.insets.inner.left))[#emph[#publication.title]
          #links(
            labeled(publication.venue, publication.doi),
            ..publication.extra_links.map(x => labeled(..x)),
          )
        ]
      ],
    )),
  )

  let icon(name, color: style.colors.shade-fg) = text(
    font: style.fonts.icons,
    size: style.header.contact.icon.size,
    weight: "bold",
    fill: color,
    fa.at(name),
  )

  let contact-column(items) = grid(
    columns: (style.header.contact.icon.width, auto),
    rows: (auto, auto),
    gutter: style.header.contact.box.gutter,
    ..items.map(item => (
      align(center)[#icon(item.icon)],
      align(left)[#text(fill: style.colors.shade-fg, size: style.header.contact.text.size)[#item.text]],
    )).flatten()
  )

  /// The blush contact panel: six `(icon:, text:)` items in three columns.
  let contact-box(items) = block(
    width: 100%,
    fill: style.colors.shade,
    radius: style.header.contact.box.radius,
    inset: style.header.contact.box.inset,
    grid(
      columns: (auto, auto, auto),
      gutter: 1fr,
      contact-column(items.slice(0, 2)),
      contact-column(items.slice(2, 4)),
      contact-column(items.slice(4, 6)),
    ),
  )

  /// The name, a "Last updated" date flush right, and the contact panel.
  let header(name, contact-info, updated: datetime.today()) = [
    #stack(
      align(left, text(..style.header.name, name)),
      align(bottom + right, text(size: 15pt, [Last updated: #updated.display("[month repr:long] [day], [year]")], style: "italic", font: style.fonts.body)),
      dir: ltr,
    )
    #v(style.header.vertical_padding)
    #contact-info
  ]

  (
    style: style,
    diamond: diamond,
    rule: rule,
    labeled: labeled,
    emphasis: emphasis,
    links: links,
    titled-list: titled-list,
    titled-block: titled-block,
    stack-unbreakable: stack-unbreakable,
    section-list: section-list,
    sections: sections,
    subsection: subsection,
    subsections-list: subsections-list,
    entry-heading: entry-heading,
    entry: entry,
    entries: entries,
    review-venue-entry: review-venue-entry,
    review-venues: review-venues,
    authors: authors,
    publication-entry: publication-entry,
    icon: icon,
    contact-column: contact-column,
    contact-box: contact-box,
    header: header,
  )
}

/// The CV page: US letter, the page number in the primary at the foot,
/// links underlined in the primary.
#let cv-page(body, style: cv-style(), title: none) = {
  set document(title: title) if title != none
  set page(
    margin: (x: 2.5cm, y: 2cm),
    paper: "us-letter",
    footer: context [
      #set align(center)
      #counter(page).display(n => text(font: style.fonts.body, fill: style.colors.primary, size: 14pt)[#n])
    ],
  )
  set text(font: style.fonts.body)
  set par(leading: 1em)
  set block(spacing: 0em)
  show link: it => text(fill: style.colors.primary, underline(it))
  body
}
