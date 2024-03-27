#import "extract.typ": extract
#import "split.typ": split
#import "util.typ": inline

// Sets the font size so the resulting text height matches the given height.
//
// If not specified otherwise in "text-args", the top and bottom edge of the
// resulting text element will be set to "bounds". If the given body does not
// contain any text, the original body is returned with only the given
// arguments applied.
//
// Parameters:
// - height: The target height of the resulting text.
// - threshold: The maximum difference between target and actual height.
// - text-args: Arguments to be passed to the underlying text element.
// - body: The content of the text element.
//
// Returns: The text with the set font size.
#let sized(height, ..text-args, threshold: 0.1pt, body) = context {
  let styled-text = text.with(
    top-edge: "bounds",
    bottom-edge: "bounds",
    ..text-args.named(),
    body
  )

  let size = height
  let font-height = measure(styled-text(size: size)).height

  // This should only take one iteration, but just in case...
  let i = 0
  while font-height > 0pt and i < 100 and calc.abs(font-height - height) > threshold {
    size *= 1 + (height - font-height) / font-height
    font-height = measure(styled-text(size: size)).height
    i += 1
  }

  return if i < 100 {
    styled-text(size: size)
  } else {
    // Font size calculation did not converge, as there is probably no text
    // that can be set to the given height. Return the original text instead,
    // with only the given arguments applied.
    text(..text-args.named(), body)
  }
}

// Resolves the given height to an absolute length.
//
// Height can be given as an integer, which is interpreted as the number of
// lines, or as a length.
//
// Requires context.
#let resolve-height(height) = {
  if type(height) == int {
    // Create dummy content to convert line count to height.
    let sample-lines = range(height).map(_ => [x]).join(linebreak())
    measure(sample-lines).height
  } else {
    height.to-absolute()
  }

}

// Shows the first letter of the given content in a larger font.
//
// If the first letter is not given as a positional argument, it is extracted
// from the content. The rest of the content is split into two pieces, where
// one is positioned next to the dropped capital, and the other below it.
//
// Parameters:
// - height: The height of the first letter. Can be given as the number of
//           lines (integer) or as a length.
// - justify: Whether to justify the text next to the first letter.
// - gap: The space between the first letter and the text.
// - hanging-indent: The indent of lines after the first line.
// - overhang: The amount by which the first letter should overhang into the
//             margin. Ratios are relative to the width of the first letter.
// - depth: The minimum space below the first letter. Can be given as the
//          number of lines (integer) or as a length.
// - transform: A function to be applied to the first letter.
// - text-args: Named arguments to be passed to the underlying text element.
// - body: The content to be shown.
//
// Returns: The content with the first letter shown in a larger font.
#let dropcap(
  height: 2,
  justify: auto,
  gap: 0pt,
  hanging-indent: 0pt,
  overhang: 0pt,
  depth: 0pt,
  transform: none,
  ..text-args,
  body
) = layout(bounds => context {  
  let (letter, rest) = if text-args.pos() == () {
    extract(body)
  } else {
    // First letter already given.
    (text-args.pos().first(), body)
  }

  if transform != none {
    letter = transform(letter)
  }

  let letter-height = resolve-height(height)
  let depth = resolve-height(depth)

  // Create dropcap with the height of sample content.
  let letter = box(
    height: letter-height + depth,
    sized(letter-height, letter, ..text-args.named())
  )
  let letter-width = measure(letter).width

  // Resolve overhang if given as percentage.
  let overhang = if type(overhang) == ratio {
    letter-width * overhang
  } else if type(overhang) == relative {
    letter-width * overhang.ratio + overhang.length
  } else {
    overhang
  }

  // Resolve justify if given as auto.
  let justify = if justify == auto { par.justify } else { justify }

  // Try to justify as many words as possible next to dropcap.
  let bounded = box.with(width: bounds.width - letter-width - gap + overhang)

  let index = 1
  let top-position = 0pt
  let (first, second) = while true {
    let (first, second) = split(rest, index)
    let first = {
      set par(hanging-indent: hanging-indent, justify: justify)
      first
    }

    let new = split(first, -1).at(1)
    top-position = calc.max(
      top-position,
      measure(bounded(first)).height - measure(new).height - par.leading.to-absolute()
    )

    if top-position >= letter-height + depth {
      // Limit reached, new element doesn't fit anymore
      split(rest, index - 1)
      break
    }

    if second == none {
      // All content fits next to dropcap.
      (first, none)
      break
    }
    
    index += 1
  }

  // Layout dropcap and aside text as grid.
  set par(justify: justify)

  let last-of-first-inline = inline(split(first, -1).at(1))
  let first-of-second-inline = second != none and inline(split(second, 1).at(0))
  let func = if last-of-first-inline { box } else { block }

  func(grid(
    column-gutter: gap,
    columns: (letter-width - overhang, 1fr),
    move(dx: -overhang, letter),
    {
      set par(hanging-indent: hanging-indent)
      first
      
      if last-of-first-inline and first-of-second-inline {
        linebreak(justify: justify)
      } 
    }
  ))

  if func == box { linebreak() }
  second
})
