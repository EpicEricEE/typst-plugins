# outex
A package for styling outlines similar to LaTeX.

## Usage
Applying this style is as simple as adding a show rule to your document. The `outex` function comes with a few options that can be used to customize the style of the outline:

| Option | Description | Default |
| --- | --- | --- |
| `gap` | The gap between numbering and section title | `1em` |
| `fill-pad` | The padding around the "fill" line | `(left: 0.5em, right: 1em)` |
| `bold` | Whether the first-level titles should be bold | `true` |
| `space` | Whether to add block-spacing before fist-level titles | `true` |


```typ
#import "@preview/outex:0.1.0": outex

#set heading(numbering: "1.1 i")

#show: outex
#show heading: set block(below: 1em)

#outline(title: "Table of Contents")

// ...
```

![Result of example code.](assets/example.svg)
