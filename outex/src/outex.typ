// Layout a heading entry in an outline.
//
// Parameters:
// - entry: The entry to apply the layout on.
// - gap: The gap between numbering and section title.
// - fill-pad: The padding around the "fill" line.
// - bold: Whether to embolden first-level section titles.
// - space: Whether to add block-spacing before fist-level titles.
//
// Returns: The styled entry.
#let heading-entry(entry, gap, fill-pad, bold, space) = style(styles => {
  let el = entry.element
  let level = str(el.level)
  
  let number = if el.numbering != none {
    locate(loc => numbering(el.numbering, ..counter(heading).at(el.location())))
  }

  let page = {
    let page-numbering = el.location().page-numbering()
    if page-numbering == none { page-numbering = "1" }
    numbering(page-numbering, el.location().page())
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

  locate(loc => {
    let state = state.final(loc)
    let indent = range(1, el.level).map(level => {
      state.number-widths.at(str(level), default: 0pt)
    }).sum(default: 0pt)

    let number-width = state.number-widths.at(level)
    let page-width = state.page-width
    let fill = if el.level > 1 { entry.fill }

    // Add links
    let linked = link.with(el.location())
    let number = linked(number)
    let title = linked(el.body)
    let page = linked(page)

    set text(weight: "bold") if bold and el.level == 1

    box(grid(
      columns: (indent, number-width, 1fr, page-width),
      [],
      number,
      title + box(width: 1fr, pad(x: fill-pad, fill)),
      align(bottom+end, page)
    ))
  })
})

// Layout a figure entry in an outline.
//
// Parameters:
// - entry: The entry to apply the layout on.
// - gap: The gap between numbering and figure caption.
// - fill-pad: The padding around the "fill" line.
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

  locate(loc => {
    let state = state.final(loc)

    let number-width = state.number-width
    let page-width = state.page-width

    // Add links
    let linked = link.with(el.location())
    let number = linked(number)
    let title = linked(el.caption.body)
    let page = linked(page)

    box(grid(
      columns: (number-width, gap, 1fr, page-width),
      align(end, number),
      [],
      title + box(width: 1fr, pad(x: fill-pad, entry.fill)),
      align(bottom+end, page)
    ))
  })
})

// Template to apply for a LaTeX styled outline.
//
// Parameters:
// - gap: The gap between numbering and section title. (Default: 1em)
// - fill-pad: The padding around the "fill" line. (Default: 0.5em)
// - bold: Whether to embolden first-level section titles. (Default: true)
// - space: Whether to add block-spacing before fist-level titles. (Default: true)
// - body: The content to apply the template on.
//
// Returns: The passed content with the styles applied.
#let outex(
  gap: 1em,
  fill-pad: 1em,
  bold: true,
  space: true,
  body
) = {
  set outline(fill: line(
    start: (100%, 0%),
    end: (0%, 0%),
    stroke: (dash: ("dot", 6pt))
  ))
  
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
