#import "../src/lib.typ": unit

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
  [*Input*],                      [*Output*],
  [`#unit("kilo meter")`],        [#unit("kilo meter")],
  [`#unit[meter squared]`],       [#unit[meter squared]],
  [`#unit[joule per kilo gram]`], [#unit[joule per kilo gram]],
  [`#unit[kg m^2/s^2]`],          [#unit[kg m^2/s^2]],
  [`#unit[per second]`],          [#unit[per second]],
  [`$unit("cm"^-1)$`],            [$unit("cm"^-1)$],
)
