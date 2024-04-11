// Typst Template by: Andrew Mitchell - andrew.mitchell.18@ucl.ac.uk

// This Typst template has been produced to exactly mimic the LaTeX template provided for INTER-NOISE 2024
// The text maintains the references to LaTeX at this stage as a demonstration of parity between the two formats.

// ---- Define custom variables ----
#let YearConf = "2024"
#let CityConf = "NANTES"
#let CityConfa = "Nantes"
#let DateConf = [25-28 August #YearConf]
#let CountryConf = "France"
#let LogoConf = "logo_IN24.jpg"
#let CopyrightConf = [
  Permission is granted for the reproduction of a fractional part of this paper published in the Proceedings of INTER-NOISE #YearConf #underline[provided permission is obtained] from the author(s) and #underline[credit is given] to the author(s) and these proceedings.
]

// ---- Document template ----

#let project(
  // Article's title
  title: [], 

  // A dictionary of authors
  //
  // Example:
  // authors: (
  //   (name: "Given name Family name1", 
  //   email: "mail1@example.com", 
  //   affiliation: "Institution", 
  //   postal: "Full address"),
    
  //   (name: "Given name Family name", 
  //   email: "mail2@example.com", 
  //   affiliation: "Institution",
  //   postal: "Full address"),
  // ),
  authors: (), 

  // The paper's abstract
  abstract: [], 

  // The paper's acknowledgements
  acknowl: none,

  // Path to the bib file
  bib: none,
  
  body
) = {
    
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  show link: set text(blue)

  set page(
    margin: (left: 20mm, right: 20mm, top: 22mm, bottom: 20mm),
    header: locate(
      loc => if [#loc.page()] != [1] [
        #align(center)[
          Proceedings of INTER-NOISE #YearConf
        ]
        #line(length: 100%)
        #v(.65em)
      ]
    ),
    footer: locate(
      loc => if [#loc.page()] == [1] [
        #set text(size: 9pt)
        #align(center)[#CopyrightConf]
      ]
    )
  )
  
  set text(font: "Minion Pro", lang: "en", size: 12pt, hyphenate: false)

  // Math formatting
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): it => block({
    set text(weight: 400)
    v(0.4em)
    it
    v(0.2em)
  })

  // Figure formatting
  set figure(gap: 2em)
  show figure: it => align(center)[
    #block({
      v(0.65em)
      it
  })
  #h(1cm)
  ]

  show figure.caption: it => [
    #align(left)[
    #set par(justify: true)
    #it.supplement
    #it.counter.display(it.numbering):
    #it.body
    ]
  ]

  // Table Formatting
  // show table.where(y: 0): strong 
  // show figure.where(
  //   kind: table
  // ): set figure.caption(position: top)

  // List formatting
  set list(marker: [--], indent: 1em)
  show list: it => block({
    v(0.45em)
    it
    v(0.45em)
  })

  // Set paragraph spacing.
  set par(leading: 0.65em, first-line-indent: 1cm)
  show par: set block(above: 0.65em, below: 0.65em)

  // Heading Formatting
  set heading(numbering: "1.1.")
  show heading: set text(size: 12pt, weight: "bold")
  show heading: it => block({
    v(.35em)
    if it.numbering != none{
    counter(heading).display()
    h(.1em)
  }
    it.body
  })

  show heading.where(level: 1): set text(size: 12pt, weight: "bold")
  show heading.where(level: 1): it => block({
    v(.35em)
    if it.numbering != none{
    counter(heading).display()
    h(1em)
  }
    upper(it.body)
    v(.1em)
  })


  // ---- Start Typesetting page ----

  // logo
  v(-2mm)
  align(center)[
  #box(
    image(LogoConf),
    width: 5.06cm
  )]
  v(0.9cm)
  
  // Title row.
  align(left)[
    #block(text(weight: "bold", 16pt, title))
  ]

  // Author information.
  pad(
    top: 0.5cm,
    // bottom: 0.3em,
    // x: 2em,
    grid(
      columns: 1,
      gutter: 2em,
      ..authors.map(author => align(left)[
        #author.name #if "email" in author [#footnote(author.email)] \
        #author.affiliation \
        #author.postal
      ]),
    ),
  )

  // ---- Main body ----
  set par(justify: true)

  // Abstract
  v(1em)
  align(center)[
  #text(weight: "bold", [ABSTRACT])
  // #heading(outlined: false, numbering: none, text(0.85em, [ABSTRACT]))
  ]
  h(-1cm)
  text(style: "italic", abstract)

  // body text
  body

  // Display Acknowledgements
  if acknowl != none {
    heading(bookmarked: false, level: 1, numbering: none, [
      #set text(size: 12pt)
      Acknowledgements
      ])
    acknowl
  }

  // Display bibliography
  if bib != none {
    show bibliography: set text(1em)
    show bibliography: set par(first-line-indent: 0em)
    bibliography(
      bib, 
      title: [
        #set text(size: 12pt)
        References
        ], 
        style: "ieee-mod.csl")
    // Closest styles to bibtex's unsrt format:
    // "american-institute-of-aeronautics-and-astronautics"
    // "american-society-of-mechanical-engineers"
    // "trends"
  }
}