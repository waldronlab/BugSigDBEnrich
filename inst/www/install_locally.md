# Run locally

If you prefer to run this app locally, install the `BugSiGDBEnrich` package on
your machine and launch the app directly from R.

+ Install package:

```r
BiocManager::install("waldronlab/BugSigDBEnrich", dependencies = TRUE)
```

+ Run the app:

```r
BugSigDBEnrich::BugSigDBEnrich()
```

**Note:** For now, you might need to keep and eye on the console when
launching the app, confirmation for caching the BugSigDB data will be
required.