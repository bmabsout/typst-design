#import "../lib.typ": *

#let style = cv-style(owner: "Author A.")
#let kit = cv-kit(style)
#show: cv-page.with(style: style, title: "A. Author: CV")
#set page(height: auto, margin: (x: 2cm, y: 1.5cm), footer: none)

#(kit.header)("A. Author", (kit.contact-box)((
  (icon: "email", text: [a\@example.com]), (icon: "location", text: [City, Country]),
  (icon: "globe", text: [example.com]), (icon: "github", text: [github.com/author]),
  (icon: "phone", text: [+1 555 0100]), (icon: "scholar", text: [Google Scholar]),
)), updated: datetime(year: 2026, month: 1, day: 1))
#v(1em)
#(kit.sections)(
  (kit.section)("Education", (
    (kit.entry)((kit.entry-heading)(l: [Ph.D. in Computer Science], m: [A University], r: [2019 -- 2024]),
      [Dissertation: _A Title Set in Italic_ #(kit.links)((kit.labeled)("pdf", link("https://example.com")[example.com/thesis]))]),
    (kit.entry)((kit.entry-heading)(l: [B.S. in Mathematics], m: [Another University], r: [2015 -- 2019]), []),
  )),
  (kit.section)("Publications", (
    (kit.publication-entry)((authors: "Author A.* and Author B.* and Author C.", title: [A Paper Title Set in Italic], venue: "Venue", year: 2024, doi: link("https://example.com")[10.0000/example], citations: 12, extra_links: (("code", link("https://example.com")[example.com/code]),)), [[1]]),
    (kit.publication-entry)((authors: "Author D. and Author A.", title: [Another Paper], venue: "Journal", year: 2023, doi: link("https://example.com")[10.0000/other], extra_links: ()), [[2]]),
  )),
)
