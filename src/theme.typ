// THEME: a look as data, and the kit drawn in it.
//
// A theme names what a look is made of: an identity ramp, the paper, the ink,
// the ramps behind the roles and the callouts, and the faces. Everything else
// follows from the sampling rules, exactly as it does for the default look.
// `theme()` with no arguments is that default, so a theme names only what
// differs:
//
//   #let look = theme(identity: rgb("#3b1319"), paper: oklch(97.5%, 0.008, 75deg))
//
// `themed(look)` then returns the kit in that look: the theme's colors, and
// every component that takes a color or a face with the theme's already
// applied (`.with`), so a document imports its kit from one file and never
// passes a color by hand. Any argument can still be overridden at the call,
// because each component is the package's own function with new defaults.

#import "color.typ" as colors: ramp-from, palette-of, roles-of, tones, quiet, readable
#import "type.typ" as typography: label-text
#import "marks.typ": capsule, capsule-rule, diamond, sep
#import "callouts.typ": callouts
#import "templates/document.typ": section-title, panel, accent, document

/// A theme. Every argument defaults to the package's own look.
///
/// - `identity`: the identity ramp, or one color to grow it from
///   (`ramp-from`). Headings, labels, links, rules and notes sample it.
/// - `paper`: the ground. Text colors are deepened until they read on it.
/// - `ink`, `ink-muted`: body text and its secondary.
/// - `ramps`: named ramps to add to the package's or to replace them. The
///   identity is also reachable as `ramps.identity`.
/// - `roles`: the ramps behind `observed`, `acted` and `valued`, by name.
/// - `callouts`: the ramps behind `note`, `theorem`, `algorithm` and
///   `notice`, by name. Notes take the identity unless named here.
/// - `faces`: font stacks to replace, by name (`serif`, `sans`, `display`,
///   `mono` and the rest of `faces`).
/// - `chart`: the categorical series colors, or `auto` for the package's.
#let theme(
  identity: colors.ramps.maroon,
  paper: white,
  ink: colors.palette.ink,
  ink-muted: colors.palette.ink-muted,
  ramps: (:),
  roles: (:),
  callouts: (:),
  faces: (:),
  chart: auto,
) = {
  let identity = if type(identity) == color { ramp-from(identity) } else { identity }
  let all = colors.ramps + (identity: identity) + ramps
  let role-ramps = (observed: all.blue, acted: all.rose, valued: all.teal) + roles
  (
    identity: identity,
    paper: paper,
    ramps: all,
    role-ramps: role-ramps,
    callout-ramps: (note: identity, theorem: all.rose, algorithm: all.blue, notice: all.orange) + callouts,
    faces: typography.faces + faces,
    palette: palette-of(identity, paper: paper, ink: ink, ink-muted: ink-muted),
    roles: roles-of(role-ramps.observed, role-ramps.acted, role-ramps.valued, on: paper),
    chart: if chart == auto { colors.chart } else { chart },
  )
}

/// The package's own look, as a theme.
#let default-theme = theme()

/// The kit in a theme's look: the theme's fields (`palette`, `ramps`,
/// `roles`, `faces`, `chart`, `paper`, `identity`) and every component that
/// draws in a color or a face, with the theme's applied.
///
///   #let (palette, ramps, note, capsule-rule, working-document) = themed(look)
#let themed(t) = {
  let d = diamond.with(fill: t.palette.mark-fill, stroke: 0.1em + t.palette.mark-line)
  let c = callouts(
    note-ramp: t.callout-ramps.note,
    theorem-ramp: t.callout-ramps.theorem,
    algorithm-ramp: t.callout-ramps.algorithm,
    notice-ramp: t.callout-ramps.notice,
  )
  t + (
    theme: t,
    // Color, measured on this paper.
    readable: readable.with(on: t.paper),
    tones: tones,
    quiet: quiet,
    // Marks.
    capsule: capsule,
    capsule-rule: capsule-rule.with(paint: t.palette.rule),
    diamond: d,
    sep: sep.with(diamond: d),
    // Type.
    label-text: label-text.with(font: t.faces.sans),
    // Callouts, in the theme's ramps.
    callouts: callouts.with(
      note-ramp: t.callout-ramps.note,
      theorem-ramp: t.callout-ramps.theorem,
      algorithm-ramp: t.callout-ramps.algorithm,
      notice-ramp: t.callout-ramps.notice,
    ),
    note: c.note,
    theorem: c.theorem,
    algorithm: c.algorithm,
    notice: c.notice,
    // The working document.
    section-title: section-title.with(palette: t.palette),
    panel: panel.with(palette: t.palette),
    accent: accent.with(palette: t.palette),
    working-document: document.with(palette: t.palette),
  )
}
