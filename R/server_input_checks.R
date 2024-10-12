
## These are used in the server_main_results file
whichType <- function(x) {
    dplyr::case_when(
        stringr::str_detect(x, "^\\d+$") ~ "ncbi",
        stringr::str_detect(x, "^[a-zA-Z]{1}__.*?(\\|[a-zA-Z]{1}__.*?)*$") ~ "metaphlan",
        stringr::str_detect(x, "^.+$") ~ "taxname",
        is.na(x) ~ NA
    )
}

isType <- function(input_sig, input_type) {
    whichType(input_sig) == input_type
}