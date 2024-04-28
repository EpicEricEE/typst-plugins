#import "/src/lib.typ": dropcap

#set page(width: 4.6cm, height: auto, margin: 1em)

// Test correct splitting of text.

#dropcap[
  This test verifies that the package doesn't split words at apostrophes.
]

#dropcap(justify: true, gap: 2pt)[
  This test verifies that the package doesn't split words at apostrophes.
]
