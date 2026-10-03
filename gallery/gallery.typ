// The gallery: the whole system on a few pages. Build with
//   typst compile --root . gallery/gallery.typ gallery/gallery.pdf
#import "../lib.typ": *

#set document(title: "typst-design — gallery", author: "Bassel El Mabsout")
#set page(paper: "us-letter", margin: (x: 0.9in, y: 0.85in), footer: context align(center, text(fill: palette.primary, size: 0.85em, counter(page).display())))
#set text(font: faces.serif, size: 10.5pt, fill: palette.ink)
#set par(leading: 0.62em, justify: true)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  text(font: faces.display, size: scale(4), weight: 600, fill: palette.primary, it.body)
  v(-0.3em)
  capsule-rule()
  v(0.4em)
}
#show heading.where(level: 2): it => block(above: 1.6em, below: 0.7em, label-text(it.body, fill: palette.primary))
#show raw: set text(font: faces.mono, size: 0.85em)

#let caption(body) = text(size: scale(-1), fill: palette.ink-muted, style: "italic", body)
#let chip(c, name, sub: none) = box(width: 6.2em, {
  box(width: 100%, height: 2.4em, fill: c, radius: 0.25em)
  v(0.15em)
  text(size: scale(-1.5), font: faces.sans, weight: 600, name)
  linebreak()
  text(size: scale(-2), fill: palette.ink-muted, if sub == none { c.to-hex() } else { sub })
})

// ------------------------------------------------------------------ cover --
#v(1fr)
#text(font: faces.display, size: scale(7), weight: 600, fill: palette.primary)[typst-design]
#v(-1.2em)
#text(font: faces.display, size: scale(2), style: "italic", fill: palette.secondary)[Bassel El Mabsout's design system, in Typst]
#v(0.2em)
#capsule-rule()
#v(0.6em)
#text(size: scale(1))[
  Every colour is a sample of an OKLCH ramp#diamond()structure comes from a capsule rule and a diamond#diamond()one serif carries every sentence.
]
#v(1fr)
#grid(columns: (1fr,) * 9, gutter: 0.35em, ..ramps.pairs().filter(((n, _)) => n != "black").map(((n, g)) => stack(spacing: 0.4em, rect(width: 100%, height: 9em, radius: 0.2em, fill: gradient.linear(..g.stops(), space: g.space(), angle: 90deg)), text(font: faces.sans, size: scale(-2.5), weight: 600, upper(n)))))
#v(2em)

= Colour
Each ramp is a straight line through OKLCH from black to white at one hue. A colour is named by its ramp and a position — `ramps.maroon.sample(30%)` — and the hex beneath each chip is what that position prints, never an input. Change a ramp's few numbers and every heading, rule, callout and plot follows.

== The ramps and where each job samples
#let bar(g) = swatch(g, width: 100%, height: 1.4em, samples: 160)
#let ramp-row(name, g, at) = block(breakable: false, below: 1.1em, {
  text(font: faces.sans, size: scale(-2), weight: 600, upper(name))
  v(-0.6em)
  box(width: 100%, {
    bar(g)
    for (label, t) in at {
      place(dx: t - 0.3em, dy: -1.15em, circle(radius: 0.3em, fill: g.sample(t), stroke: 0.1em + white))
      place(dx: t - 2em, dy: 0.15em, box(width: 4em, align(center, text(size: scale(-2.5), fill: palette.ink-muted)[#label #str(int(t / 1%))%])))
    }
  })
})
#ramp-row("maroon — identity", ramps.maroon, (("ink", 15%), ("h1", 30%), ("h2", 45%), ("h3", 60%), ("blush", 82%), ("rule", 90%)))
#ramp-row("blue — observed, algorithms", ramps.blue, (("ink", 15%), ("title", 35%), ("role", 55%), ("chart", 63%)))
#ramp-row("rose — acted, theorems", ramps.rose, (("ink", 15%), ("title", 35%), ("chart", 48%), ("role", 55%)))
#ramp-row("teal — valued, results", ramps.teal, (("ink", 15%), ("title", 35%), ("role", 55%), ("chart", 63%)))
#ramp-row("orange — warnings (interpolated in OKLab)", ramps.orange, (("ink", 15%), ("notice", 50%)))

== The palette
#grid(columns: (1fr,) * 5, row-gutter: 0.8em, ..palette.pairs().map(((name, c)) => chip(c, name)))

== Roles
The same colour marks a role in prose, in equations and in plots: what is #text(fill: roles.observed)[observed], what is #text(fill: roles.acted)[acted], what is #text(fill: roles.valued)[valued].
$ #rl.at + pi(#rl.st) quad #rl.Q (#rl.st, #rl.at) = #rl.rt + gamma #rl.V (#rl.stp1) $

== Chart slots
Fixed order, never cycled; neighbours alternate between 63% and 48% lightness so they part for colour-blind readers too.
#grid(columns: (1fr,) * 6, ..chart.enumerate().map(((i, c)) => chip(c, "chart-" + str(i + 1))))

== Callout tones
#let tone-row(name, g) = block(breakable: false, {
  text(font: faces.sans, size: scale(-2), weight: 600, upper(name))
  grid(columns: (1fr,) * 6, ..tones(g).pairs().map(((k, c)) => chip(c, k)))
})
#tone-row("maroon", ramps.maroon)
#tone-row("rose", ramps.rose)

== The fulfillment scale
#swatch(fulfillment, width: 100%, height: 1.4em, samples: 160)
#caption[`fulfillment`: bad to good in five OKLCH stops, the identity's crimson through copper, amber and green to the `valued` teal. Low is urgent. Every sample is dark enough for text, and the ends part by lightness and blue, not only by red and green.]

= Type and marks
#grid(columns: (1fr, 1fr), gutter: 1.5em,
  [
    == Faces
    #text(font: faces.serif, size: scale(1))[Source Serif 4] — every sentence. \
    #text(font: faces.display, size: scale(2), weight: 600)[Crimson Pro] — names, titles. \
    #label-text[Source Sans 3] — labels only. \
    #text(font: faces.garamond, size: scale(1))[EB Garamond] — the CV family. \
  ],
  [
    == One ×1.2 scale
    #for s in range(4, -3, step: -1) [#text(size: scale(s, base: 10.5pt))[Step #s] #h(0.5em) #text(size: scale(-2), fill: palette.ink-muted)[#calc.round(10.5 * calc.pow(1.2, s), digits: 1)pt] \ ]
  ],
)
== Headings darken with rank
#text(size: scale(3), weight: "bold", fill: ramps.maroon.sample(30%))[1 Chapter] \
#text(size: scale(2), weight: "bold", fill: ramps.maroon.sample(45%))[1.1 Section] \
#text(size: scale(1), weight: "bold", fill: ramps.maroon.sample(60%))[1.1.1 Subsection] \
*Definition:* run in, in ink.

== Capsule rule
#capsule-rule()
#capsule-rule(paint: palette.rule-soft)
#caption[Round-capped dots, so each reads as a capsule: the identity `rule` (maroon 90%) and the CV's softer `rule-soft`.]

== Diamond
Reinforcement Learning#diamond()Embedded Systems#diamond()Type Theory#diamond()Control Systems \
#text(size: scale(3))[Large#diamond()and#diamond()small] #text(size: scale(-1))[it scales#diamond()with text]

= Callouts

#note(title: [Markov Decision Process])[A tuple $(#rl.S, #rl.A, TT, #rl.R)$ of states, actions, transitions and rewards.]
#theorem(title: [Semantic Preservation])[A theorem takes the rose ramp, numbered so it can be referenced.]
#algorithm(title: [Balanced Policy Gradient])[An algorithm takes the blue ramp.]
#notice[a warning has no title and opens in the orange ramp's 50% sample.]

= Templates
== CV
#let k = cv-kit(cv-style(owner: "Author A."))
#block(width: 100%, {
  set text(font: faces.garamond)
  (k.section-list)("Education", (
    (k.entry)((k.entry-heading)(l: [Ph.D. in Computer Science], m: [A University], r: [2019 -- 2024]), [Dissertation: _A Title in Italic_ #(k.links)((k.labeled)("dissertation", link("https://example.com")[example.com/thesis]), (k.labeled)("code", link("https://example.com")[example.com/code]))]),
    (k.entry)((k.entry-heading)(l: [B.S. in Mathematics], m: [Another University], r: [2015 -- 2019]), []),
  ))
  v(1em)
  (k.contact-box)((
    (icon: "email", text: [name\@example.com]), (icon: "location", text: [City, Country]),
    (icon: "globe", text: [example.com]), (icon: "github", text: [github.com/you]),
    (icon: "phone", text: [+1 555 0100]), (icon: "scholar", text: [Google Scholar]),
  ))
})
#caption[`cv-style(ramp: ramps.maroon)` — pass another ramp and the whole CV recolours.]

== Recoloured from one argument
#block(width: 100%, {
  set text(font: faces.garamond)
  let k = cv-kit(cv-style(ramp: ramps.blue, owner: "Author A."))
  (k.section-list)("Publications", ((k.publication-entry)((authors: "Author A.* and Author B.* and Author C.", title: [A Paper Title Set in Italic], venue: "Venue", year: 2024, doi: [10.0000/example], citations: 12, extra_links: ()), [[1]]),))
})

== FPL marks
#for v in (0.08, 0.35, 0.62, 0.9) [#price(v) #h(1.2em)]
#price(none)
#v(0.5em)

#trace((0.9, 0.85, 0.8, 0.72, 0.6, 0.5, 0.42, 0.38, 0.33, 0.3, 0.27, 0.24, 0.2), back: 6, ahead: 6, at: datetime(year: 2026, month: 10, day: 3))

#caption[`pie`, `price` and `trace`: a value's colour is always `colour(v)`, a sample of the one scale.]
