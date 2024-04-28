#import "/src/lib.typ": dropcap

#set page(width: 6cm, height: auto, margin: 1em)
#set par(justify: true)

// Test arguments for customization.

#dropcap(height: 3, lorem(14))
#dropcap(height: 1.1cm, lorem(14))
#dropcap(depth: 2, lorem(23))
#dropcap(height: 5mm, depth: 5mm, lorem(16))
#dropcap(overhang: 1em, lorem(7))
#dropcap(overhang: 100%, lorem(7))
#dropcap(overhang: -1em, gap: 1em, lorem(12))
#dropcap(height: 3, hanging-indent: 1em, lorem(13))
#dropcap(
  gap: 8pt,
  fill: white,
  font: "New Computer Modern",
  style: "italic",
  transform: letter => {
    h(4pt) + box(fill: blue, letter + h(10pt), outset: 3pt)
  },
  lorem(11)
)
