#import "/src/lib.typ": equate

#set page(width: 6cm, height: auto, margin: 1em)
#show: equate

// Test correct number position when using `set align`.

#set math.equation(numbering: "(1)")

#for number-align in (left, right) {
  set math.equation(number-align: number-align)

  $ a + b $
  show math.equation: set align(start)
  $ a + b $
  show math.equation: set align(end)
  $ a + b $
}

// Test alignment points together with `set align`.

#show math.equation: set align(start)

$ a + b &= c &+ d = e \
      f &= g &    = h $
