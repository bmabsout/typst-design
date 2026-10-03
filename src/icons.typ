// ICONS: Font Awesome 5 glyphs, used only in contact lists.

#import "type.typ": faces

/// Code points by name (Font Awesome 5 Free / Brands).
#let fa = (
  phone: "\u{f095}",
  location: "\u{f3c5}",
  email: "\u{f0e0}",
  globe: "\u{f0ac}",
  github: "\u{f09b}",
  scholar: "\u{f19d}",
  linkedin: "\u{f08c}",
)

/// One glyph by name, bold so the solid style is chosen.
#let icon(name, fill: auto, size: auto, font: faces.icons) = {
  let args = (font: font, weight: "bold")
  if fill != auto { args.insert("fill", fill) }
  if size != auto { args.insert("size", size) }
  text(..args, fa.at(name))
}
