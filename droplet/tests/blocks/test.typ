#import "/src/lib.typ": dropcap

#set page(width: 6cm, height: auto, margin: 1em)

// Test block content within a dropcap.

#dropcap(height: 1cm, gap: 4pt)[
  Einstein said that mass and energy go like
  $ E = m c^2 $
  and it was true (mostly).
]

#dropcap(height: 1cm, gap: 3pt)[
  There is a rectangle below

  #align(center, rect())

  but it's still beside the first letter.
]
