// MATH: role colors in equations, a few operators, and abbreviations.
//
// A symbol takes its role's color wherever it appears, so `s_t` is the same
// blue in a sentence, an equation and a plot legend.

#import "color.typ": roles

#let observed(body) = text(fill: roles.observed, $#body$)
#let acted(body) = text(fill: roles.acted, $#body$)
#let valued(body) = text(fill: roles.valued, $#body$)

/// The reinforcement-learning names for the three roles.
#let state(body) = text(fill: roles.observed, $#body$)
#let action(body) = text(fill: roles.acted, $#body$)
#let reward(body) = text(fill: roles.valued, $#body$)
#let state-color = roles.observed
#let action-color = roles.acted
#let reward-color = roles.valued

/// The usual symbols, already colored.
#let rl = (
  st: state($s_t$),
  stp1: state($s_(t+1)$),
  sp: state($s'$),
  S: state($S$),
  a: action($a$),
  at: action($a_t$),
  A: action($A$),
  R: reward($R$),
  rt: reward($r_t$),
  Q: reward($Q$),
  V: reward($V$),
)

/// The power mean $overline(mu)_p$.
#let pmean(p) = $overline(mu)_#p$

/// A boxed operator with its argument set small inside: FPL's `⊡_p`.
#let fbox(p) = math.op(limits: true, box(inset: 0em, grid(
  line(length: 0.2em, stroke: 0.5pt),
  text(box(inset: 0.2em, $#p$), size: 0.75em, top-edge: "bounds", bottom-edge: "bounds"),
  line(length: 0.2em, stroke: 0.5pt),
  align: horizon + center,
  columns: 3,
), stroke: 0.5pt))

#let vecand = math.and.big
#let vecor = math.or.big
#let loss = math.op($cal(L)$)
#let expect = math.op($EE$, limits: true)
#let policy = math.op($pi$, limits: true)
#let sigmoid(x) = $phi(x)$

/// Small stacked equations, for a margin or a figure.
#let stack-math(..maths, size: 9pt) = {
  set text(size: size)
  stack(dir: ttb, spacing: 1em, ..maths)
}

/// An unmissable marker for unfinished text.
#let todo(message) = text(red, [TODO: #message])

// ---------------------------------------------------------- abbreviations --

/// One abbreviation's four forms, as a dictionary to merge with others:
/// - `abbrv.X`: the first use spells it out ("Fulfillment Priority Logic
///   (FPL)"), every later one is the short form, linked to the table.
/// - `abbrv.X_full`, `abbrv.X_long`, `abbrv.X_short`: that form always.
#let make-abbrv(short, full) = (
  (short): context box([
    #let first_check = counter(full).get().first()
    #if first_check == 0 {
      [#full (#short)#counter(full).step()]
    } else {
      link(label(short), [#short])
    }
  ]),
  (short + "_full"): link(label(short), box[#full (#short)]),
  (short + "_long"): box(full),
  (short + "_short"): link(label(short), box(short)),
)

/// Merge many: `abbreviations(("RL", "Reinforcement Learning"), …)`.
#let abbreviations(..pairs) = pairs.pos().map(((s, f)) => make-abbrv(s, f)).sum(default: (:))

/// The table of abbreviations, each short form labeled so uses link to it.
/// No rules: alternate rows are striped in `stripe`.
#let abbreviation-table(abbrv, stripe: white.darken(5%), columns: (0.4fr, 1fr)) = {
  let entries = ()
  for (key, value) in abbrv {
    if key.ends-with("_short") {
      let short = key.slice(0, -6)
      let full_key = short + "_long"
      if full_key in abbrv {
        entries.push([#value #label(short)])
        entries.push([#abbrv.at(full_key)])
      }
    }
  }
  table(
    align: (left, left),
    columns: columns,
    stroke: none,
    fill: (_, y) => if calc.odd(y) { stripe },
    [*Abbreviation*], [*Full Form*#v(1em)],
    ..entries,
  )
}
