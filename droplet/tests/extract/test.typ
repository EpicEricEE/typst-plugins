#import "/src/lib.typ": dropcap

#set page(width: 6cm, height: auto, margin: 1em)

// Test that the first letter is extracted correctly.

#dropcap[First letter]
#dropcap[1. Wash your hands]
#dropcap[“This is a quote,” said someone.]
#dropcap[#super[1] In the beginning...]
#dropcap[H#sub[2] is hydrogen.]
#dropcap[#box[This] is a boxed word.]
