#import "/src/lib.typ": dropcap

#set page(width: 4.6cm, height: auto, margin: 1em)

// Test correct splitting of text.

#dropcap[
  This test verifies that the package doesn't split words at apostrophes.
]

#dropcap(justify: true, gap: 2pt)[
  This test verifies that the package doesn't split words at apostrophes.
]

#dropcap(justify: true)[
  Here are two rectangles #box(width: 1em, height: 3em, baseline: 2.34em, fill: red) #box(width: 1em, height: 4em, baseline: 3.34em, fill: red) in red and there is text beside.
]

#dropcap(height: 1.1em,)[
  This is an equation $(display(integral F = 0))$ test, which tests stuff.
]
