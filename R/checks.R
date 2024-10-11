
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