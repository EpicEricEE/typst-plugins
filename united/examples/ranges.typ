#import "../src/lib.typ": numrange, qtyrange

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
  background: box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
  ),
)

#table(
  columns: 2,
  [*Input*],                         [*Output*],
  [`#numrange(2, 5)`],               [#numrange(2, 5)],
  [`#numrange[1.2e2][1.8e2]`],       [#numrange[1.2e2][1.8e2]],
  [`#numrange[1.25e2][5.3e3]`],      [#numrange[1.25e2][5.3e3]],
  [`#qtyrange[36(1)][38][celsius]`], [#qtyrange[36(1)][38][celsius]],
  [`#qtyrange[10][1e8][cm^-1]`],     [#qtyrange[10][1e8][cm^-1]],
)
