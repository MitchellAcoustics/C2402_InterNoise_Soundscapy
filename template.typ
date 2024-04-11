// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}

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
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates


#show: project.with(
      title: "Soundscapy: A python package for soundscape assessment and analysis

",
        authors: (
                ( 
            name: "Andrew Mitchell",
                          affiliation: "Bartlett School of Sustainable Construction",
              postal: "University College London, London, UK",
                        email: "andrew.mitchell.18\@ucl.ac.uk" 
          ),
          ),
        abstract: [Soundscape questionnaires are widely used to gather subjective information about people’s perceptions and attitudes towards their acoustic environment. Despite the widespread adoption of ISO/TS 12913-3 guidelines for analyzing soundscape survey data, there are still several misapplications and interpretations. A recent study has proposed an innovative visualization approach for soundscape data analysis, using a probabilistic method that depicts the collective perception of a soundscape as a distribution of responses within the circumplex. To bring this method to life, a new open-source python package called Soundscapy has been developed. The main goal of this software is to enable the easy, accessible, and consistent application of analysis for soundscape data collected according to the ISO 12913 methods. This conference paper outlines the important features of Soundscapy, explains its basic functioning, lists its current capabilities, and gives recommendations for its best use. Finally, the future development of Soundscapy is proposed, including the integration of psychoacoustic analysis, predictive soundscape models, and soundscape indices for use in automated assessment and design.

],
          bib: "FellowshipRefs-biblatex.bib",
  )

#show heading: set text(size: 12pt, weight: "bold")

= Introduction
<introduction>
== Overview of soundscape assessment and analysis
<overview-of-soundscape-assessment-and-analysis>
Soundscapy is a python toolbox for analysing quantitative soundscape data. Urban soundscapes are typically assessed through surveys which ask respondents how they perceive the given soundscape. Particularly when collected following the technical specification ISO 12913 Part 3 #cite(<ISO12913Part3>);, these surveys can constitute a rich source of data for soundscape analysis. Soundscapy aims to provide a comprehensive set of tools for analysing such data, including functions for data validation, analysis, and visualization.

As proposed by Mitchell, Aletta, & Kang #cite(<Mitchell2022How>);, in order to describe the soundscape perception of a group or of a location, we should consider the distribution of responses. Soundscapy’s approach to soundscape analysis follows this idea, providing functions for visualizing the distribution of responses to soundscape questionnaires.

To support this work, international standards like #cite(<ISO12913Part3>) have been developed to provide a framework for the measurement, analysis, and reporting of soundscape perception. Soundscapy is a new open-source Python package that aligns with the requirements outlined in this standard, aiming to make advanced soundscape analysis techniques accessible to a wide audience. By basing its core functionality on ISO 12913-3, Soundscapy aims to lower the barriers to entry and enable more people to conduct high-quality soundscape research.

== Soundscape Assessment Framework in Soundscapy
<soundscape-assessment-framework-in-soundscapy>
At the core of Soundscapy are functions for validating, analysing, and visualising soundscape data.

Soundscapy’s design is closely tied to the guidance provided in ISO 12901303

= Background
<background>
#quote(block: true)[
#strong[ISO 12913-3] is the international standard for soundscape surveys, which provides guidelines for the collection and analysis of soundscape data. The standard outlines a structured approach to soundscape data collection, including the use of questionnaires, sound recordings, and environmental measurements. The standard also provides a framework for the analysis of soundscape data, including the calculation of soundscape indices and the visualization of soundscape maps.
]

= Soundscapy: History and description
<soundscapy-history-and-description>
#quote(block: true)[
Soundscapy is built on outcomes from the Soundscape Indices \(SSID) project. The SSID project aimed to develop a new method for analyzing soundscape data that could provide more detailed insights into the perception of soundscapes. The SSID method uses a probabilistic approach to model the distribution of responses to soundscape questionnaires, allowing researchers to explore the relationships between different soundscape attributes and the overall soundscape quality.
]

#cite(<Mitchell2022How>)

== Databases
<databases>
Soundscapy was primarily developed to work with the International Soundscape Database \(ISD) #cite(<Mitchell2021International>);, which I will describe here and use for the examples in this paper. The ISD is a large database of soundscape recordings and survey data collected according to the SSID Protocol #cite(<Mitchell2020Soundscape>);. The database contains over 3,000 recordings, each with a corresponding survey that includes information about the soundscape, the location, and the respondents. The ISD is freely available to researchers and can be used to study a wide range of soundscape-related topics.

The ISD contains three primary types of data - surveys, pre-calculated psychoacoustic metrics, and binaural audio recordings. The surveys include several blocks of questions, the most important of which are the Perceptual Attribute Questions \(PAQs). These form the 8 descriptors of the soundscape circumplex #cite(<Axelsson2010principal>) - pleasant, vibrant, eventful, chaotic, annoying, monotonous, uneventful, and calm. In addition, each survey includes other information about the soundscape and demographic characteristics \(age, gender, etc.). Finally, the survey section includes identifiers of when and where the survey was conducted - the `LocationID`, `SessionID`, `latitude`, `longitude`, `start_time`, etc.

The ISD is included with Soundscapy and can be loaded with the following code:

#block[
```python
import soundscapy as sspy
df = sspy.isd.load()
df, excl_df = sspy.isd.validate(df)
df = sspy.isd.add_iso_coords(df)
```

]
== Visualizing soundscape data
<visualizing-soundscape-data>
Visualizing soundscape data is crucial for exploring patterns and communicating findings. Soundscapy includes functions for creating

#block[
```python
sspy.plotting.density(
  df.query("LocationID == 'CamdenTown'"),
  figsize=(4, 4),
)
```

]
== Psychoacoustic Analysis
<psychoacoustic-analysis>
#strong[— Expand here —]

This has been optimised for performing batch processing of many recordings, ease of use, and reproducibility. To do this, we rely on three packages to provide the analysis functions:

- Python Acoustics \(`acoustics`) : Python Acoustics is a library aimed at acousticians. It provides two benefits - first, the analysis functions are referenced directly to the relevant standard. Second, Soundscapy subclasses the `Signal` class to provide the binaural functionality, and any function available within the `Signal` class is also available to Soundscapy’s `Binaural` class.
- scikit-maad #cite(<Ulloa2021scikit>) \(`maad`) : scikit-maad is a modular toolbox for quantitative soundscape analysis, focused on ecological soundscapes and bioacoustic indices. scikit-maad provides a huge suite of ecosoundscape focused indices, including Acoustic Richness Index, Acoustic Complexity Index, Normalized Difference Soundscape Index, and more.
- MoSQITo \(`mosqito`) : MoSQITo is a modular framework of key sound quality metrics, providing the psychoacoustic metrics for Soundscapy.

#figure([
```python
from soundscapy import Binaural
b = Binaural.from_wav(wav_dir.joinpath("CT101.wav"))
b.plot();
```

], caption: figure.caption(
separator: "", 
position: bottom, 
[
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-binaural>


The metrics currently available are:

- Python Acoustics : $L_(Z e q)$, $L_(A e q)$, $L_(C e q)$, SEL, and all associated statistics \($L_5$ through $L_95$, $L_(m a x)$ and $L_(m i n)$, as well as kurtosis #cite(<Qiu2020Kurtosis>) and skewness).
- scikit-maad : So far, only the combined `all_temporal_alpha_indices` and `all_spectral_alpha_indices` functions from `scikit-maad` have been implemented; calculating them individually is not yet supported. `all_temporal_alpha_indices` comprises 16 temporal domain acoustic indices, such as temporal signal-to-noise ratio, temporal entropy, and temporal events. `all_spectra_alpha_indices` comprises 19 spectral domain acoustic indices, such as the Bioacoustic Index, Acoustic Diversity Index, NDSI, Acoustic Evenness Index, and Acoustic Complexity Index.
- MoSQITo : #emph[cont.]

Soundscapy combines all of these metrics and makes it easy and \(relatively) fast to compute any or all of them for a binaural audio recording. These results have been preliminarily validated through comparison of results obtained from Head Acoustics ArtemiS suite on a set of real-world recordings.

#figure([
```python
metric = "LAeq"
stats = ("avg", 10, 50, 90, 95, "max")
label = "LAeq"
res_df = b.pyacoustics_metric(metric, stats, label)
res_df.round(2)
```

], caption: figure.caption(
position: top, 
[
Psychoacoustic metrics calculated by Soundscapy
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
numbering: "1", 
)
<tbl-psycho>


=== Consistent Analysis Settings
<consistent-analysis-settings>
A primary goal when developing this library was to make it easy to save and document the settings used for all analyses. This is done through a `settings.yaml` file and the `AnalysisSettings` class. Although the settings for each metric can be set at runtime, the settings.yaml file allows you to set all of the settings at once and document exactly what settings were passed to each analysis function and to share these settings with collaborators or reviewers.

=== Defining Analysis Settings
<defining-analysis-settings>
Soundscapy provides the ability to predefine the analysis settings. These are defined in a separate `.yaml` file and are managed by Soundscapy using the `AnalysisSettings` class. These settings can then be passed to any of the analysis functions, rather than separately defining your settings as we did above. This is particularly useful when performing batch processing on an entire folder of wav recordings.

Soundscapy provides a set of default settings which can be easily loaded in:

#block[
```python
analysis_settings = sspy.AnalysisSettings.default()
```

]
and the settings file for the Loudness calculation can be printed:

#block[
```python
analysis_settings['MoSQITo']['loudness_zwtv']
```

]
These settings can then be passed to any of the analysis functions, like the following function which will calculate all of the metrics requested in the settings file:

#block[
```python
res_df = b.process_all_metrics(analysis_settings, verbose=False)
```

]
=== Batch Processing
<batch-processing>
The other primary goal was to make it simple and fast to perform this analysis on many recordings. One aspect of this is unifying the outputs from the underlying libraries and presenting them in an easy to parse format. The analysis functions from Soundscapy can return a MultiIndex pandas DataFrame with the Recording filename and Left and Right channels in the index and a column for each metric calculated. This dataframe can then be easily saved to a .csv or Excel spreadsheet. Alternatively, a dictionary can be returned for further processing within Python. The key point is that after calculating 100+ metrics for 1,000+ recordings, you’ll be left with a single tidy spreadsheet.

The Soundscape Indices \(SSID) project for which this was developed has over 3,000 recordings for which we needed to calculate a full suite of metrics for both channels. In particular, the MoSQITo functions can be quite slow, so running each recording one at a time can be prohibitively slow and only utilize a small portion of the available computing power. To help with this, a set of simple functions is provided to enable parallel processing, such that multiple recordings can be processed simultaneously by a multi-core CPU.

#block[
```python
ser_start = time.perf_counter()
for wav in wav_dir.glob("*.wav"):
  recording = wav.stem
  decibel = tuple(levels[recording].values())
  b = Binaural.from_wav(wav, calibrate_to=decibel)
  ser_df = add_results(df, b.process_all_metrics(analysis_settings, verbose=False))
ser_end = time.perf_counter()
```

] <serial-process>
#block[
```python
par_start = time.perf_counter()
par_df = parallel_process(
  wav_dir.glob("*.wav"), df, levels, analysis_settings, verbose=False)
par_end = time.perf_counter()
```

] <parallel-process>
In our initial tests on a 16-core AMD Ryzen 7 4800HS CPU \(Fedora Linux 36), this increased the speed for processing 20 recordings by at least 8 times.

In testing, the MoSQITo functions are particularly slow, taking up to 3 minutes to calculate the Loudness for a 30s two-channel recording. When running only a single recording through, this has also been sped up by parallelizing the per-channel calculation, reducing the computation time to around 50s.

= Future development
<future-development>
In addition to continuing to improve the core functionality of Soundscapy, there are several areas where future development will be focused. Primarily, we aim to develop and integrate predictive soundscape models, which will allow us to predict the soundscape quality of a location based on its acoustic characteristics #cite(<Mitchell2023conceptual>);. This will involve developing machine learning models that can predict soundscape quality based on acoustic features, such as sound levels, frequency content, and temporal patterns.

#figure([
#box(width: 100%,image("Soundscapy2.png"))
], caption: figure.caption(
position: bottom, 
[
Future development plans for Soundscapy
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-future>


= Conclusions
<conclusions>
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Mi eget mauris pharetra et. Senectus et netus et malesuada fames ac. Nibh sed pulvinar proin gravida hendrerit lectus. Magna ac placerat vestibulum lectus mauris. In nulla posuere sollicitudin aliquam ultrices. Adipiscing bibendum est ultricies integer quis auctor. Mollis nunc sed id semper risus in. Neque laoreet suspendisse interdum consectetur libero id faucibus. Elit pellentesque habitant morbi tristique senectus et netus et. Pulvinar neque laoreet suspendisse interdum consectetur libero. Porta nibh venenatis cras sed. Tristique nulla aliquet enim tortor at auctor. Pellentesque diam volutpat commodo sed egestas egestas. Elit sed vulputate mi sit amet mauris.

Ipsum nunc aliquet bibendum enim facilisis. Mauris a diam maecenas sed enim ut sem. Et tortor consequat id porta nibh. Duis at consectetur lorem donec massa sapien faucibus et molestie. Nisl rhoncus mattis rhoncus urna neque viverra justo nec. Vulputate odio ut enim blandit. Nulla facilisi etiam dignissim diam quis enim. At augue eget arcu dictum varius duis at consectetur. Phasellus vestibulum lorem sed risus ultricies tristique nulla aliquet enim. Amet risus nullam eget felis eget nunc lobortis mattis. Sit amet nisl suscipit adipiscing. Pharetra et ultrices neque ornare aenean.

Molestie nunc non blandit massa enim. Volutpat diam ut venenatis tellus in metus vulputate eu scelerisque. Molestie at elementum eu facilisis sed odio. Hendrerit dolor magna eget est lorem ipsum dolor sit amet. Ipsum dolor sit amet consectetur adipiscing elit. Congue eu consequat ac felis donec et odio pellentesque. Proin nibh nisl condimentum id venenatis a. Molestie a iaculis at erat. Fermentum leo vel orci porta non pulvinar neque laoreet. Sed adipiscing diam donec adipiscing tristique risus nec feugiat in. Tellus cras adipiscing enim eu turpis egestas pretium. Cursus mattis molestie a iaculis at erat pellentesque adipiscing commodo. Elementum pulvinar etiam non quam lacus suspendisse. Gravida quis blandit turpis cursus in.

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
[
Acknowledgements
]
)
]



