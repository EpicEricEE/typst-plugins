// Repeat the given content to fill the full space.
//
// Parameters:
// - gap: The gap between repeated items. (Default: none)
// - justify: Whether to increase the gap to justify the items. (Default: false)
//
// Returns: The repeated content.
#let repeat(
  gap: none,
  justify: false,
  body
) = layout(size => style(styles => {
  let pt(length) = measure(h(length), styles).width
  let width = measure(body, styles).width
  let amount = calc.floor(pt(size.width + gap) / pt(width + gap))

  let gap = if not justify { gap } else {
    (size.width - amount * width) / (amount - 1)
  }
  
  let items = ((box(body),) * amount)
  if type(gap) == length and gap != 0pt {
    items = items.intersperse(h(gap))
  }

  items.join()
}))

// Layout a heading entry in an outline.
//
// Parameters:
// - entry: The entry to apply the layout on.
// - gap: The gap between numbering and section title.
// - fill-pad: A dict (left, right) of the padding around the "fill" line.
// - bold: Whether to embolden first-level section titles.
// - space: Whether to add block-spacing before fist-level titles.
//
// Returns: The styled entry.
#let heading-entry(entry, gap, fill-pad, bold, space) = style(styles => {
  let el = entry.element
  let level = str(el.level)
  
  let number = if el.numbering != none {
    numbering(el.numbering, ..counter(heading).at(el.location()))
  }

  let page = {
    let page-numbering = el.location().page-numbering()
    if page-numbering == none { page-numbering = "1" }
    numbering(page-numbering, ..counter(page).at(el.location()))
  }

  let number-width = measure(number + h(gap), styles).width
  let page-width = measure(page, styles).width
  
  // Keep track of the maximum widths of the numbering and page.
  let state = state("outex:0.1.0/heading", (
    number-widths: (:),
    page-width: 0pt,
  ))

  state.update(state => {
    let number-widths = state.number-widths
    if level in number-widths {
      number-widths.at(level) = calc.max(number-widths.at(level), number-width)
    } else {
      number-widths.insert(level, number-width)
    }

    (
      page-width: calc.max(state.page-width, page-width),
      number-widths: number-widths
    )
  })

  // Add paragraph spacing
  if el.level == 1 and space { parbreak() }

  // Add links
  let linked = link.with(el.location())
  let number = linked(number)
  let title = linked(el.body)
  let page = linked(page)

  locate(loc => {
    let state = state.final(loc)
    let indent = range(1, el.level).map(level => {
      state.number-widths.at(str(level), default: 0pt)
    }).sum(default: 0pt)

    let number-width = if el.numbering == none { 0pt } else {
      state.number-widths.at(level)
    }

    let page-width = state.page-width
    let fill = if el.level > 1 { entry.fill }

    set text(weight: "bold") if bold and el.level == 1

    box(grid(
      columns: (indent, number-width, 1fr, page-width),
      [],
      number,
      pad(
        right: fill-pad.right,
        title + box(width: 1fr, pad(left: fill-pad.left, fill))
      ),
      align(bottom+end, page)
    ))
  })
})

// Layout a figure entry in an outline.
//
// Parameters:
// - entry: The entry to apply the layout on.
// - gap: The gap between numbering and figure caption.
// - fill-pad: A dict (left, right) of the padding around the "fill" line.
//
// Returns: The styled entry.
#let figure-entry(entry, gap, fill-pad) = style(styles => {
  let el = entry.element
  
  let number = if el.numbering != none {
    locate(loc => numbering(el.numbering, ..el.counter.at(el.location())))
  }

  let page = {
    let page-numbering = el.location().page-numbering()
    if page-numbering == none { page-numbering = "1" }
    numbering(page-numbering, el.location().page())
  }

  let number-width = measure(number, styles).width
  let page-width = measure(page, styles).width
  
  // Keep track of the maximum widths of the numbering and page.
  let state = state("outex:0.1.0/figure/" + repr(el.kind), (
    number-width: 0pt,
    page-width: 0pt,
  ))

  state.update(state => {(
    page-width: calc.max(state.page-width, page-width),
    number-width: calc.max(state.number-width, number-width)
  )})

  // Add links
  let linked = link.with(el.location())
  let number = linked(number)
  let title = linked(el.caption.body)
  let page = linked(page)

  locate(loc => {
    let state = state.final(loc)
    let number-width = state.number-width
    let page-width = state.page-width

    box(grid(
      columns: (number-width, gap, 1fr, page-width),
      align(end, number),
      [],
      pad(
        right: fill-pad.right,
        title + box(width: 1fr, pad(left: fill-pad.left, entry.fill))
      ),
      align(bottom+end, page)
    ))
  })
})

// Template to apply for a LaTeX styled outline.
//
// Parameters:
// - gap: The gap between numbering and section title. (Default: 1em)
// - fill-pad: The padding around the "fill" line. (Default: (left: 0.5em, right: 1em))
// - bold: Whether to embolden first-level section titles. (Default: true)
// - space: Whether to add block-spacing before fist-level titles. (Default: true)
// - body: The content to apply the template on.
//
// Returns: The passed content with the styles applied.
#let outex(
  gap: 1em,
  fill-pad: (left: 0.5em, right: 1em),
  bold: true,
  space: true,
  body
) = {
  set outline(fill: align(end, repeat(gap: 0.5em, ".")))

  // Convert fill-pad to dict
  let fill-pad = if type(fill-pad) == dictionary {(
    left: fill-pad.at("left", default: 0pt),
    right: fill-pad.at("right", default: 0pt)
  )} else {(
    left: fill-pad,
    right: fill-pad
  )}
  
  show outline.entry: it => {
    let el = it.element
    if el.func() == heading {
      return heading-entry(it, gap, fill-pad, bold, space)
    } else if el.func() == figure {
      return figure-entry(it, gap, fill-pad)
    }
    it
  }

  body
}
