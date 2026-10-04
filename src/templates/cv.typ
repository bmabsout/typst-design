// CV: the curriculum vitae's building blocks: sections over capsule rules,
// entries with a date flush right, labeled links joined by diamonds,
// publications and a blush contact panel.
//
// `cv-kit(style)` returns every block configured by one style dictionary.
// `cv-style(..)` builds that dictionary from the identity's defaults, so a
// document overrides only what differs.

#import "../color.typ": palette, ramps, ramp-from, quiet, stops, readable, text-needs
#import "../type.typ": faces
#import "../marks.typ": capsule-rule, diamond as _diamond
#import "../icons.typ": fa

/// The CV's style. Colors are the identity's ramp samples, and faces default to
/// the CV family (EB Garamond, Libertinus Sans labels).
#let cv-style(
  ramp: ramps.maroon,
  primary: auto,
  secondary: auto,
  link: auto,
  shade: auto,
  shade-line: auto,
  rule: auto,
  body: faces.garamond,
  sans: faces.libertinus-sans,
  icons: faces.icons,
  owner: none,
) = {
  // Every color is a sample or a quiet tone of one ramp: pass `ramp` (a
  // ramp, or one color to grow it from) to recolor the whole CV, or a
  // single named color to override just that one.
  // `ramp` may also be a single color: the ramp is grown from it.
  let ramp = if type(ramp) == color { ramp-from(ramp) } else { ramp }
  let pick(v, d) = if v == auto { d } else { v }
  let primary = pick(primary, ramp.sample(stops.strong))
  // Subsections, links and the contact lines are set at body size, so they
  // take their samples through `readable`.
  let secondary = pick(secondary, readable(ramp, stops.medium))
  let link = pick(link, readable(ramp, stops.strong))
  let shade-fill = pick(shade, quiet(ramp, stops.fill))
  let shade-line = pick(shade-line, quiet(ramp, stops.line))
  let rule = pick(rule, quiet(ramp, stops.rule))
  let contact = readable(ramp, stops.strong, on: shade-fill)
  (
  colors: (
    primary: primary,
    secondary: secondary,
    link: link,
    shade: shade-fill,
    shade-fg: contact,
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
  /// A line of labeled links under an entry, joined by diamonds, aligned
  /// with the entry's text.
  let links(..items) = [\ #items.pos().join([#diamond()])]

  /// A title kept with its first item. The rest may break.
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

  /// The first child stays with `first`, the last with `last`, and the middle
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

  /// An entry's heading row: bold title, italic organization, the date flush
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

  /// Authors joined by diamonds, the owner in bold. `names` is an array,
  /// or a string joined by " and ". `owner` is matched exactly when given
  /// here, and by substring when it comes from the style.
  let authors(names, owner: auto) = {
    let names = if type(names) == str { names.split(" and ") } else { names }
    let bold(name) = if owner != auto { name == owner } else { style.owner != none and name.contains(style.owner) }
    names.map(name => if bold(name) [*#name*] else { name }).join([#diamond()])
  }

  /// A publication: its number, the authors with the year (and citations)
  /// flush right, then the italic title, an optional note, and labeled
  /// links. `publication` is a dictionary with `authors` (array or string),
  /// `title`, `venue` and `year`, and optionally `doi` (none for a venue with
  /// no link), `citations`, `note` and `extra_links`.
  let publication-entry(publication, label) = {
    set par(leading: style.spacing.paragraph)
    let doi = publication.at("doi", default: none)
    let note = publication.at("note", default: none)
    let citations = publication.at("citations", default: 0)
    grid(
      columns: (auto, 1fr),
      gutter: 1em,
      [#label],
      block(breakable: false, stack(
        spacing: style.spacing.paragraph,
        [
          #authors(publication.authors)
          #h(1fr)
          #smallcaps([#(if citations != 0 [#smallcaps[(citations: #citations) ]])#publication.year])
        ],
        [
          #block(inset: (left: style.insets.inner.left))[#emph[#publication.title]#if note != none [ \ #note]
            #links(
              if doi == none { text(weight: 600, publication.venue) } else { labeled(publication.venue, doi) },
              ..publication.at("extra_links", default: ()).map(x => labeled(..x)),
            )
          ]
        ],
      )),
    )
  }

  /// A contact icon: a key of `fa`, or ready-made content (another glyph).
  let icon(name, color: style.colors.shade-fg) = if type(name) != str { name } else {
    text(
      font: style.fonts.icons,
      size: style.header.contact.icon.size,
      weight: "bold",
      fill: color,
      fa.at(name),
    )
  }

  let contact-column(items) = grid(
    columns: (style.header.contact.icon.width, auto),
    gutter: style.header.contact.box.gutter,
    ..items.map(item => (
      align(center)[#icon(item.icon)],
      align(left)[#text(fill: style.colors.shade-fg, size: style.header.contact.text.size)[#item.text]],
    )).flatten()
  )

  /// The blush contact panel of `(icon:, text:)` items. Six items sit in
  /// three columns of two. Any other number sits one item per column.
  let contact-box(items) = block(
    width: 100%,
    fill: style.colors.shade,
    radius: style.header.contact.box.radius,
    inset: style.header.contact.box.inset,
    if items.len() == 6 {
      grid(
        columns: (auto, auto, auto),
        gutter: 1fr,
        contact-column(items.slice(0, 2)),
        contact-column(items.slice(2, 4)),
        contact-column(items.slice(4, 6)),
      )
    } else {
      grid(
        columns: items.len() * (auto,),
        column-gutter: 1fr,
        ..items.map(item => contact-column((item,))),
      )
    },
  )

  /// The name, a "Last updated" date flush right, and the contact panel.
  /// `updated` is a datetime, or content such as a source document's date.
  let header(name, contact-info, updated: datetime.today()) = {
    let date = if type(updated) == datetime { updated.display("[month repr:long] [day], [year]") } else { updated }
    [
      #stack(
        align(left, text(..style.header.name, name)),
        align(bottom + right, text(size: 15pt, [Last updated: #date], style: "italic", font: style.fonts.body)),
        dir: ltr,
      )
      #v(style.header.vertical_padding)
      #contact-info
    ]
  }

  /// A section that breaks gently: only the title is kept with what follows,
  /// and every child may break, so long lists (awards, talks, courses) do
  /// not leave half-empty pages. It looks the same as `section-list`.
  let section(title, children) = {
    let spacing = style.spacing.section
    let inset = (left: style.insets.section.left)
    block(breakable: false, sticky: true)[
      #rule
      #v(spacing)
      #text(..style.section, upper(title))
    ]
    v(style.insets.section.top)
    children.slice(0, -1).map(c => block(inset: inset, c) + v(spacing, weak: true)).join()
    block[#block(inset: inset, children.last())#v(spacing)#rule]
  }

  /// An entry heading that wraps cleanly: the date keeps its own column and
  /// wrapped lines get the entries' leading and a hanging indent.
  let wrapping-heading(l: none, m: none, r: none) = {
    set par(leading: style.spacing.paragraph, hanging-indent: 1em)
    grid(
      columns: (1fr, auto),
      column-gutter: 1.5em,
      par[#text(weight: style.entry.heading.weight, l)#if m != none [#h(0.5em)#emph(m)]],
      smallcaps(lower(r)),
    )
  }

  /// A one-line entry for lists such as awards or courses, with an optional
  /// indented note.
  let row(l, m: none, r: none, body: []) = entry(wrapping-heading(l: l, m: m, r: r), body)

  /// A titled list of rows, closer together than full entries.
  let row-list(title, rows) = titled-list(text(..style.subsection, title), rows, style.insets.inner, style.spacing.paragraph)

  /// A subsection of label and items rows, items joined by diamonds.
  let labeled-rows(title, pairs) = subsection((
    title: title,
    body: {
      set par(leading: style.spacing.paragraph)
      grid(
        columns: (auto, 1fr),
        column-gutter: 1em,
        row-gutter: 0.8em,
        ..pairs.map(((name, items)) => (text(weight: "bold", smallcaps(name)), items.join([#diamond()]))).flatten()
      )
    },
  ))

  /// A talk: the title and date on the first line, then the venue and any
  /// co-authors.
  let talk(title, venue, date, with: none) = entry(
    wrapping-heading(l: emph(title), r: date),
    [#venue#if with != none [#diamond()#authors(with)]],
  )

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
    section: section,
    wrapping-heading: wrapping-heading,
    row: row,
    row-list: row-list,
    labeled-rows: labeled-rows,
    talk: talk,
  )
}

/// The CV page: US letter, the page number in the primary at the foot,
/// links underlined in the link color.
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
  show link: it => text(fill: style.colors.link, underline(it))
  body
}
