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
  [`#unit("kilo meter")`],       [#unit("kilo meter")],
  [`#unit[meter squared]`],      [#unit[meter squared]],
  [`#unit[joule per kilogram]`], [#unit[joule per kilogram]],
  [`#unit[kg m^2/s^2]`],         [#unit[kg m^2/s^2]],
  [`#unit[per second]`],         [#unit[per second]],
  [`#unit['apples' per day]`],   [#unit['apples' per day]],
  [`$unit("cm"^-1)$`],           [$unit("cm"^-1)$],
)
