#import "/src/lib.typ": dropcap

#set page(width: 6cm, height: auto, margin: 1em)

// Test different justify values.

#dropcap(justify: true, lorem(20))

#set par(justify: true)

#dropcap(justify: auto, lorem(20))
#dropcap(justify: false, lorem(20))
