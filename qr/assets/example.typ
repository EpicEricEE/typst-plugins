#import "../src/lib.typ" as qr

#set text(size: 14pt)
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
  inset: 0.5em,
  align: horizon,

  table.header[*Data*][*QR Code*],

  [Hello world!],  qr.create("Hello world!", margin: 0, width: 100%),
  [Hallo Welt!],   qr.create("Hallo Welt!", fill: blue, width: 100%),
  [#(1, 2, 3, 4)], box(fill: yellow, qr.create((1, 2, 3, 4), width: 100%)),
)
