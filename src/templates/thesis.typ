// THESIS: a dissertation with front matter numbered in roman, chapters that
// open on a new column with a capsule rule and a local contents, headings
// that darken with rank along one ramp, references colored like their
// target, and Boston University's required pages.
//
// `thesis-style(..)` is the whole look as data, and `make-template(style)`
// returns the page builders and `assemble`, the show rule.

#import "../color.typ": ramps, ref-ramp, stops, jobs, quiet, readable, text-needs
#import "../type.typ": font-options
#import "../marks.typ": capsule-rule
#import "../callouts.typ": callouts

/// The colors a thesis is set in, by ramp. `compliance: "bu"` sets the
/// headings black, as Boston University's thesis office requires, and keeps
/// color off the front matter: the contents title, the abstract's heading
/// and the box around its author block.
#let thesis-colors(compliance: none, primary: ramps.maroon) = (
  compliance: compliance,
  primary: if compliance == "bu" { ramps.black } else { primary },
  ref: ref-ramp,
  accent1: ramps.blue,
  accent2: ramps.rose,
  accent3: ramps.teal,
  accent4: ramps.amber,
)

/// The whole look as one dictionary: page, body text, paragraphs, and the
/// four heading levels, each sampling `colors.primary` further along.
#let thesis-style(
  colors: thesis-colors(),
  body: font-options.libertinus_serif,
  heading: font-options.libertinus_serif,
) = (
  colors: colors,
  page: (margins: (left: 1.5in, right: 1in, top: 1.5in, bottom: 1in)),
  body: (text: body),
  par: (leading: 1.5em, spacing: 2em, first-line-indent: 0em, justify: true),
  heading: (
    text: heading,
    levels: (
      (text: (size: 1.8em, weight: "bold", fill: readable(colors.primary, jobs.heading-1, need: text-needs.headline)), spacing: (above: 2em, below: 2em)),
      (text: (size: 1.5em, weight: "bold", fill: readable(colors.primary, jobs.heading-2, need: text-needs.subhead)), spacing: (above: 2em, below: 1.5em)),
      (text: (size: 1.2em, weight: "bold", fill: readable(colors.primary, jobs.heading-3, need: text-needs.subhead)), spacing: (above: 2em, below: 1.5em)),
      (text: (size: 1em, weight: "bold", fill: black)),
    ),
    // A heading's color where it is named at body size: in the contents
    // (bold) and in a reference (small capitals).
    entries: (jobs.heading-1, jobs.heading-2, jobs.heading-3, 0%).map(t => readable(colors.primary, t, need: text-needs.body)),
    refs: (jobs.heading-1, jobs.heading-2, jobs.heading-3, 0%).map(t => readable(colors.primary, t)),
  ),
  radius: 12pt,
)

/// The text arguments for a heading of `level` (0-based).
#let heading-style(style, level: 0) = style.heading.text + style.heading.levels.at(level).text

/// The rule under a chapter title and around the contents.
#let thesis-rule(style) = capsule-rule(paint: quiet(style.colors.primary, stops.rule), period: 6.1pt)

/// The chapter's own contents: its sections and subsections.
#let local-outline() = context {
  outline(target: selector(heading.where(level: 2).or(heading.where(level: 3))).after(here()).before(heading.where(level: 1).after(here())), title: none)
}

#let roman-numbering(content) = {
  counter(page).update(1)
  set page(numbering: "i", header: [], footer: context {
    align(center, text(size: 1em, counter(page).display("i")))
  })
  content
}

#let arabic-numbering(numbering: "1", content) = {
  counter(page).update(1)
  set page(numbering: numbering, footer: [], header: context align(right, text(size: 1em, counter(page).display(numbering))))
  content
}

#let ignore-page-numbering(content) = {
  set page(footer: [])
  content
}

/// The page builders and the show rule for `style`. `framed` draws the
/// abstract's author block: by default a box in the primary's tones, and
/// nothing under `compliance: "bu"`.
#let make-template(style: thesis-style(), framed: auto) = {
  let long_line = thesis-rule(style)
  let plain = style.colors.at("compliance", default: none) == "bu"
  let framed = if framed != auto { framed } else if plain { body => body } else {
    callouts(classic: true, figure: false, note-ramp: style.colors.primary).note.with(engine: block.with(width: 100%))
  }

  let assemble(
    doc,
    thesis_title: none,
    author_name: none,
    title_page: none,
    copyright_page: none,
    approval_page: none,
    acknowledgments: none,
    dedication: none,
    abstract: none,
    table_of_contents: none,
    abbreviations: none,
    list_of_figures: none,
    list_of_tables: none,
    main: none,
    appendices: none,
    bibliography: none,
    vita: none,
    local_outlines: true,
  ) = {
    set document(title: thesis_title, author: author_name)
    set page(width: 8.5in, height: 11in, margin: style.page.margins)
    set text(..style.body.text, hyphenate: false)
    set par(..style.par)

    show heading: it => {
      set text(size: style.heading.text.size)
      let level_idx = it.level - 1
      let style_props = style.heading.levels.at(level_idx)
      set text(..heading-style(style, level: level_idx))
      let spacing = style_props.at("spacing", default: (above: 0em, below: 0em))
      v(spacing.above, weak: true)
      if it.level == 1 {
        colbreak(weak: true)
        if it.numbering != none [Chapter #counter(heading).display()\ ]
        it.body
        place(long_line, dy: -style.heading.levels.at(0).spacing.below / 2)
        if local_outlines and it.numbering != none {
          local-outline()
          v(-0.2em)
          long_line
          v(-1em)
        }
      } else {
        it
      }
      v(spacing.below, weak: true)
    }

    show heading.where(level: 4): it => {
      parbreak()
      text(weight: "bold")[#box(it):#h(0.5em)]
    }

    set heading(numbering: "1.1")
    set math.equation(numbering: "(1)")
    show math.equation: it => box(it)
    set figure(gap: 1.5em)
    show figure: set block(breakable: true)

    set ref(supplement: it => {
      if it.func() == heading and it.level == 1 {
        [Chapter]
      } else if it.func() == heading {
        if it.level == 4 { [Definition] } else { [Section] }
      } else if it.func() == figure {
        it.supplement
      }
    })

    // A reference is small caps, colored like the heading it names.
    show ref: it => {
      show text: it => smallcaps(lower(it))
      if it.element != none and it.element.func() == heading {
        set text(fill: style.heading.refs.at(it.element.level - 1))
        it
      } else {
        set text(fill: style.colors.ref.sample(jobs.ref))
        it
      }
    }

    show outline: it => {
      set text(size: style.heading.text.size)
      it
    }

    let build_pages = pages => {
      for page in pages.filter(page => page != none and page != []).intersperse(pagebreak()) {
        page
      }
    }

    // Contents entries take their heading's color: everywhere, or only
    // after the front matter under `compliance: "bu"`.
    let entry-colors(body) = {
      show outline.entry: it => {
        set text(..heading-style(style, level: it.level - 1), size: 1em, fill: style.heading.entries.at(it.level - 1))
        box(it)
      }
      body
    }
    let front = roman-numbering(build_pages((
      ignore-page-numbering(title_page),
      ignore-page-numbering(copyright_page),
      ignore-page-numbering(approval_page),
      dedication,
      acknowledgments,
      abstract,
      table_of_contents,
      abbreviations,
      list_of_figures,
      list_of_tables,
    )))
    if plain { front } else { entry-colors(front) }
    entry-colors(arabic-numbering(build_pages((main, appendices, bibliography, vita))))
  }

  // ----------------------------------------------- Boston University pages --

  let make_bu_title_page(
    title_text,
    author_name,
    degree_type,
    submission_year,
    school_name_on_title_page,
    grs_name_on_title_page,
    degree_submission_text: "Dissertation submitted in partial fulfillment",
  ) = {
    set text(..style.heading.text, size: 1.2em, features: ("dlig": 0, "liga": 1, "calt": 1, "clig": 0))
    set align(center)
    [
      #upper(school_name_on_title_page)\
      #upper(grs_name_on_title_page)
      #v(0.6fr)
      #degree_submission_text
      #v(0.6fr)
      *#text(size: 1.08em, upper(title_text))*
      #v(0.3fr)
      by
      #v(0.3fr)
      #upper(author_name)
      #v(0.6fr)
      #text(size: 1em)[
        Submitted in Partial Fulfillment of the\
        Requirements for the Degree of\
        #degree_type
      ]
      #v(0.6fr)
      #submission_year
    ]
  }

  let make_bu_copyright_page(author_name, copyright_year) = {
    set text(..style.heading.text, size: 1.2em)
    v(1fr)
    stack(
      dir: ltr,
      spacing: 0.5em,
      h(1fr),
      sym.copyright,
      align(left, [
        #copyright_year by\
        #upper(author_name)\
        all rights reserved
      ]),
    )
  }

  let make_reader_block(reader) = [
    #v(5em)
    #box(line(length: 100%, stroke: (thickness: 1pt, dash: "solid", cap: "round")))\
    #reader.name\
    #reader.title\
    #reader.institution
  ]

  let make_bu_approval_page(readers_list) = {
    align(center)[Approved by]
    block(width: 100%, height: 1fr, grid(
      column-gutter: 2.2em,
      row-gutter: 1fr,
      columns: (auto, auto),
      ..readers_list.map(reader => ([#v(2.5em)#reader.ordinal Reader], make_reader_block(reader))).flatten()
    ))
  }

  let make_major_professor_block(professor) = stack(
    dir: ltr,
    spacing: 1em,
    [*Major Professor:*],
    [
      #set align(left)
      #professor.name\
      #professor.title
    ],
  )

  let make_bu_abstract_section(
    thesis_title,
    author_name,
    school_name_for_abstract,
    grs_name_for_abstract,
    degree_type,
    submission_year,
    major_professors,
    abstract_body_content,
  ) = {
    align(center)[
      #heading(level: 3, numbering: none, outlined: false, text(fill: black, upper(thesis_title)))
      #v(1em)
      #framed[
        #set align(center)
        #text(size: 1.2em)[#upper(author_name)]\
        #school_name_for_abstract, #grs_name_for_abstract, #submission_year
        #major_professors
      ]
    ]
    if plain {
      align(center)[
        ABSTRACT
      ]
    } else {
      align(center, heading(level: 2, numbering: none, outlined: false)[ABSTRACT])
    }
    abstract_body_content
  }

  // ------------------------------------------------------- generic pages --

  let make_table_of_contents(title: "Contents", depth: 2) = {
    heading(level: 2, numbering: none, outlined: false, if plain { text(size: 1em, fill: black, title) } else { title })
    long_line
    outline(title: none, indent: 3em, depth: depth)
    long_line
  }

  let make_list_of_figures(title: "List of Figures") = {
    heading(level: 2, numbering: none, outlined: false, title)
    outline(target: figure.where(kind: image))
  }

  let make_list_of_tables(title: "List of Tables") = {
    heading(level: 2, numbering: none, outlined: false, title)
    outline(target: figure.where(kind: table))
  }

  let format_appendices(body_content, title: "Appendices") = if body_content != none {
    block({
      heading(level: 1, numbering: none)[#title]
      set par(justify: true, leading: style.par.leading)
      body_content
    })
  } else { [] }

  let format_vita(vita_content, title: "Vita") = if vita_content != none {
    block({
      heading(level: 1, numbering: none)[#title]
      vita_content
    })
  } else { [] }

  (
    style: style,
    long_line: long_line,
    make_bu_title_page: make_bu_title_page,
    make_bu_copyright_page: make_bu_copyright_page,
    make_bu_approval_page: make_bu_approval_page,
    make_major_professor_block: make_major_professor_block,
    make_bu_abstract_section: make_bu_abstract_section,
    make_table_of_contents: make_table_of_contents,
    make_list_of_figures: make_list_of_figures,
    make_list_of_tables: make_list_of_tables,
    format_main_content: body => body,
    format_appendices: format_appendices,
    format_vita: format_vita,
    assemble_thesis_document: assemble,
  )
}
