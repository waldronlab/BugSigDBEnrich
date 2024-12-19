
# BugSigDBEnrich

This repo/package contains a function that runs a shinyApp for comparing a list of identifiers against the BugSigDB signatures.

## App in the CUNY SPH server

https://shiny.sph.cuny.edu/BugSigDBEnrich/

## Installation

Install with:

```r
BiocManager::install("waldronlab/BugSigDBEnrich", dependencies = TRUE)
```

## Launch the app

```r
BugSigDBEnrich::BugSigDBEnrich()
```
## Help

The help documentation can be found [here](https://github.com/waldronlab/BugSigDBEnrich/blob/devel/inst/www/help.md)
