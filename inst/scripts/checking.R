ncbi <- generateExampleText("ncbi") |> 
    strsplit("\n") |> 
    unlist()

meta <- generateExampleText("metaphlan") |> 
    strsplit("\n") |>
    unlist()

taxname <- generateExampleText("taxname") |> 
    strsplit("\n") |>
    unlist()

whichType <- function(x) {
    dplyr::case_when(
        stringr::str_detect(x, "^\\d+$") ~ "ncbi",
        stringr::str_detect(x, "^[a-zA-Z]{1}__.*?(\\|[a-zA-Z]{1}__.*?)*$") ~ "metaphlan",
        stringr::str_detect(x, "^.+$") ~ "taxname",
        is.na(x) ~ NA
    )
}

isType <- function(x, y) {
    whichType(x) == y
}

meta[length(meta)] <- "k__Bacteria"
meta[length(meta)-1] <- "Bacteria"

whichType(ncbi)
whichType(meta)
whichType(taxname)

isType(ncbi, "ncbi")
isType(ncbi, "taxname")
isType(ncbi, "metaphlan")

isType(taxname, "ncbi")
isType(taxname, "taxname")
isType(taxname, "metaphlan")

isType(meta, "ncbi")
isType(meta, "taxname")
isType(meta, "metaphlan")

if (isFALSE(all(isType(meta, "metaphlan")))) {
    warning("Something is wrong", call. = FALSE)
}

if (isFALSE(all(isType(meta, "metaphlan")))) {
    warning("Something is wrong", call. = FALSE)
}

if (isFALSE(all(isType(meta, "metaphlan")))) {
    warning("Something is wrong", call. = FALSE)
}
