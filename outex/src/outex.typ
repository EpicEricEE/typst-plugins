// Template to apply for a LaTeX styled outline.
//
// Parameters:
// - gap: The gap between numbering and section title. (Default: 1em)
// - fill-pad: The padding around the "fill" line. (Default: 0.5em)
// - bold: Whether the first-level titles should be bold. (Default: true)
// - space: Whether to add block-spacing before fist-level titles. (Default: true)
// - body: The content to apply the template on.
//
// Returns: The passed content with the styles applied.
#let outex(
  gap: 1em,
  fill-pad: 0.5em,
  bold: true,
  space: true,
  body
) = {
  set outline(fill: line(
    length: 100%,
    stroke: (dash: "loosely-dotted")
  ))
  
  show outline.entry: it => locate(loc => style(styles => {
    let el = it.element
    if el.func() != heading {
      return it
    }
  
    let title = el.body
    let page = it.page
    let fill = if it.level > 1 { it.fill }
    let number = if el.numbering != none {
      numbering(el.numbering, ..counter(heading).at(el.location()))
    }
  
    // Calculate indent of outline entry
    let indent = 0pt
    for level in range(1, el.level) {
      let widths = query(heading.where(level: level, outlined: true), loc)
        .filter(el => el.numbering != none)
        .map(el => numbering(el.numbering, ..counter(heading).at(el.location())))
        .map(number => measure(number, styles).width)
      indent += calc.max(0pt, ..widths) + gap
    }
  
    // Calculate maximum width of sibling numberings (if necessary)
    let width = if number == none { 0pt } else {
      calc.max(0pt, ..query(heading.where(level: it.level, outlined: true), loc)
        .filter(el => el.numbering != none)
        .map(el => numbering(el.numbering, ..counter(heading).at(el.location())))
        .map(number => measure(number, styles).width)) + gap
    }

    // Calculate maximum width of page numbers
    let page-numbering = el.location().page-numbering()
    if page-numbering == none { page-numbering = "1" }
    let page-width = calc.max(0pt, ..query(heading.where(outlined: true), loc)
      .map(el => numbering(page-numbering, el.location().page()))
      .map(el => measure(el, styles).width)
    ) + fill-pad

    // Style first-level headings
    if it.level == 1 {
      // Make headings bold
      if bold {
        number = strong(number)
        title = strong(title)
        page = strong(page)
      }
      
      // Start new paragraph to add space
      if space { parbreak() }
    }
  
    // Add links to elements
    let linked = link.with(el.location())
    number = linked(number)
    title = linked(title)
    page = linked(page)
  
    box(grid(
      columns: (indent, width, 1fr, page-width),
      [],
      number,
      title + h(fill-pad) + box(width: 1fr, fill),
      align(bottom+end, page)
    ))
  }))

  body
}
