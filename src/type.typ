// TYPE: the faces, the scale, and the presets each document has used.
//
// One serif carries every sentence (Source Serif 4). Crimson Pro sets names
// and titles at display sizes. Source Sans 3 sets short UPPERCASE labels.
// The CV family has set EB Garamond with Libertinus Sans labels. Those faces
// are kept as a named family rather than hard-coded in the CV.

/// Font stacks: each is a list, so a face the machine lacks falls through.
#let faces = (
  serif: ("Source Serif 4", "Libertinus Serif"),
  subhead: ("Source Serif 4 Subhead", "Source Serif 4", "Libertinus Serif"),
  display: ("Crimson Pro", "Source Serif 4", "Libertinus Serif"),
  sans: ("Source Sans 3", "Libertinus Sans"),
  math: ("New Computer Modern Math",),
  mono: ("DejaVu Sans Mono", "Libertinus Mono"),
  icons: "Font Awesome 5 Free",
  // The CV family's own pairing.
  garamond: "EB Garamond",
  libertinus-sans: "Libertinus Sans",
  libertinus: "Libertinus Serif",
)

/// The type scale: every size is `base` times 1.2 to the `step`.
/// `scale(0)` is the body size. Headings sit at steps 1–3, display at 5–7,
/// labels at −1 and −2.
#let ratio = 1.2
#let scale(step, base: 1em) = base * calc.pow(ratio, step)

/// Body-text presets, each a face at the size where its x-height matches
/// the others'. Swap one for another and a page keeps its color.
#let font-options = (
  libertinus_serif: (font: "Libertinus Serif", size: 12.4pt, weight: 400),
  new_computer_modern: (font: "New Computer Modern", size: 11.5pt),
  eb_garamond: (font: "EB Garamond", size: 13pt),
  merriweather: (font: "Merriweather", size: 10.2pt),
  source_serif_4: (font: "Source Serif 4", size: 11.3pt),
  crimson_pro: (font: "Crimson Pro", size: 12.5pt, weight: 400),
  garamontio: (font: "Garamontio", size: 13pt, weight: 400),
  libre_baskerville: (font: "Libre Baskerville", size: 9.9pt, weight: 400),
  baskervillef: (font: "BaskervilleF", size: 12pt, weight: 400),
  dejavu_serif: (font: "Dejavu Serif", size: 10pt, weight: 400),
  lato: (font: "Lato", size: 11.5pt),
)

/// An UPPERCASE, tracked label in the sans: a section title or a category.
#let label-text(body, size: scale(-1), tracking: 0.14em, weight: 600, fill: auto) = {
  let args = (font: faces.sans, size: size, tracking: tracking, weight: weight)
  if fill != auto { args.insert("fill", fill) }
  text(..args, upper(body))
}

/// Small caps from lowercase: dates, counts, minor labels.
#let minor(body) = smallcaps(lower(body))
