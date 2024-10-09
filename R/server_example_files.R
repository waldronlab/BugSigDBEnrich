getExamplePaths <- function() {
    ncbi <- system.file(
        "extdata", "ncbi.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    taxname <- system.file(
        "extdata", "taxname.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    metaphlan <- system.file(
        "extdata", "metaphlan.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    list(
        ncbi = ncbi,
        taxname = taxname,
        metaphlan = metaphlan
    )
}