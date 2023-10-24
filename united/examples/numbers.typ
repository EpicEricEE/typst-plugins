#import "../src/lib.typ": num

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
  [*Input*],              [*Output*],
  [`#num("12345")`],      [#num("12345")],
  [`#num(3.14159)`],      [#num(3.14159)],
  [`#num[3.5e5]`],        [#num[3.5e5]],
  [`#num[2.5+-0.5]`],     [#num[2.5+-0.5]],
  [`#num[3+2-1 e-3]`],    [#num[3+2-1 e-3]],
  [`$num(2.53(12)e+7)$`], [$num(2.53(12)e+7)$],
)
