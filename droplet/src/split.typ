#import "util.typ": attach-label, space, splittable

// Gets the number of words in the given content.
#let size(body) = {
  if type(body) == str {
    body.split(" ").len()
  } else if body.has("text") {
    size(body.text)
  } else if body.has("child") {
    size(body.child)
  } else if body.has("children") {
    body.children.map(size).sum()
  } else if body.func() in splittable {
    size(body.body)
  } else if body.func() == space {
    0
  } else {
    1
  }
}

// Splits the given content at a given index.
//
// Content is split at word boundaries. A sequence can be split at any of its
// childrens' word boundaries. The index may not always be a valid word
// boundary, in which case the content is split at the previous word boundary.
//
// Returns: A tuple of the first and second part.
#let split(body, index) = {
  // Handle string content.
  if type(body) == str {
    let words = body.split(" ")
    if index >= words.len() {
      return (body, none)
    }
    let first = words.slice(0, index).join(" ")
    let second = words.slice(index).join(" ")
    return (first, second)
  }

  // Handle text content.
  if body.has("text") {
    let (text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second) = split(text, index)
    return attach-label((func(first), func(second)), label)
  }

  // Handle content with "body" field.
  if body.func() in splittable {
    let (body: text, ..fields) = body.fields()
    let label = if "label" in fields { fields.remove("label") }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (first, second) = split(text, index)
    return attach-label((func(first), func(second)), label)
  }

  // Handle styled content. Unfortunately, we cannot preserve the style
  // information here, so it is dropped.
  if body.has("child") {
    let (first, second) = split(body.child, index)
    return (first, second)
  }

  // Handle sequences.
  if body.has("children") {
    let first = ()
    let second = ()

    // Find child containing the splitting point and split it.
    let new-index = index
    for (i, child) in body.children.enumerate() {
      let child-size = size(child)
      new-index -= child-size

      if new-index <= 0 {
        // Current child contains splitting point.
        let sub-index = child-size + new-index
        let (child-first, child-second) = split(child, sub-index)

        if child-second == none {
          // Split is at the end of the child, so check if next child is space.
          let next = body.children.at(i + 1, default: [ ])
          if next.func() != space {
            // Cannot split here, so split at previous break point.
            return split(body, index - 1)
          }
        }

        first.push(child-first)
        second.push(child-second)
        second += body.children.slice(i + 1)
        break
      }

      first.push(child)
    }

    return (first.join(), second.join())
  }

  // Handle unbreakable content.
  return (body, none)
}
