#import "../src/lib.typ": outex

#set text(size: 14pt)
#set heading(numbering: "1.1 i")
#set page(
  width: 10cm,
  height: auto,
  margin: 1em,
  background: box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  ),
)

#show heading: set block(below: 1em)
#show: outex

#outline(title: "Table of Contents")

#set page(height: 2cm)

= Introduction

= Background

== The Problem

== The Solution

= Implementation

== The Algorithm

== The Code

=== The Parser

=== The Compiler

== The Tests

= Conclusion

#heading(numbering: none, [References])
