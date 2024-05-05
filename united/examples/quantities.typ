#import "../src/lib.typ": qty

#set raw(lang: "typ")
#set text(size: 14pt)
#set table(
  inset: 0.7em,
  fill: (x, y) => if y == 0 { luma(230) }
)
#set page(
  width: auto,
  height: auto,
  margin: 1em,
  background: pad(0.5pt, box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  )),
)

#table(
  columns: 2,
  [*Input*],                     [*Output*],
  [`#qty(42, "µm")`],            [#qty(42, "µm")],
  [`#qty[3.5(5)][meter cubed]`], [#qty[3.5(5)][meter cubed]],
  [`#qty[1.602e-19][eV]`],       [#qty[1.602e-19][eV]],
  [`$qty(12+3-1 e-9, s)$`],      [$qty(12+3-1 e-9, s)$],
)
