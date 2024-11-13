JS <-  system.file(
    "www", "script.js", package = "BugSigDBEnrich", mustWork = TRUE
) |> 
    readLines() |> 
    paste(collapse = "\n")

CSS <- system.file(
    "www", "style.css", package = "BugSigDBEnrich", mustWork = TRUE
) |> 
    readLines() |> 
    paste(collapse = "\n")
