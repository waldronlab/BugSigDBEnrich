sets2Df <- function(x, y) {
    # print(head(x))
    # print(head(y))
    input_only <- setdiff(x, y)
    both <- intersect(x, y)
    target_only <- setdiff(y, x)
    ids <- c(input_only, both, target_only)
    # names(x) <- x
    # print(head(x))
    # ids2 <- c(
    #     names(x[input_only]),
    #     names(y)[match(both, y)],
    #     names(y)[match(target_only, y)]
    # )
    # message(length(ids))
    # message(length(ids2))
    labels <- dplyr::case_when(
        ids %in% input_only ~ "Input only",
        ids %in% both ~ "Both",
        ids %in% target_only ~ "Database only"
    )
    df <- data.frame(
        ID = ids,
        # ID2 = ids2,
        Label = labels
    )
    
    if (isType(x, "ncbi")[[1]]) {
        df <- df |> 
            dplyr::mutate(
                `Taxon name` = id2name(.data$ID)
            ) |> 
            dplyr::relocate(.data$`Taxon name`, .after = .data$ID) |> 
            dplyr::rename(`NCBI ID` = .data$ID) |> 
            dplyr::mutate(
                `NCBI ID` =    .data$`NCBI ID` |> 
                    strsplit(",") |> 
                    purrr::map(
                        ~ paste0(
                            '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
                            .x,'" target="_blank">', .x, '</a>'
                        ) |> 
                            paste(collapse = ",")
                    )
            )
    } else if (isType(x, "taxname")[[1]]) {
        df <- df |> 
            dplyr::mutate(
                `NCBI ID` = taxonomizr::getId(.data$ID, .pkgenv$ncbi_path)
            ) |> 
            dplyr::relocate(.data$`NCBI ID`, .after = .data$ID) |> 
            dplyr::rename(`Taxon name` = .data$ID) |> 
            dplyr::mutate(
                `NCBI ID` =    .data$`NCBI ID` |> 
                    strsplit(",") |> 
                    purrr::map(
                        ~ paste0(
                            '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
                            .x,'" target="_blank">', .x, '</a>'
                        ) |> 
                            paste(collapse = ",")
                    )
            )
    } else if (isType(x, "metaphlan")[[1]]) {
        df <- df |> 
            dplyr::mutate(
                `NCBI ID` = .data$ID |> 
                    stringr::str_extract("[^|]+$") |> 
                    stringr::str_remove("^[a-zA-Z]__") |> 
                    taxonomizr::getId(.pkgenv$ncbi_path)
            ) |> 
            dplyr::relocate(.data$`NCBI ID`, .after = .data$ID) |> 
            dplyr::rename(`Metaphlan name` = .data$ID) |> 
            dplyr::mutate(
                `NCBI ID` =    .data$`NCBI ID` |> 
                    strsplit(",") |> 
                    purrr::map(
                        ~ paste0(
                            '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
                            .x,'" target="_blank">', .x, '</a>'
                        ) |> 
                            paste(collapse = ",")
                    )
            )
    }
     
    return(df)
}

helpIcon <- function(inputId) {
    shiny::actionLink(
        inputId = inputId,
        label = bsicons::bs_icon("question-circle")
    ) 
}

id2name <- function(x) {
    taxonomizr::getCommon(x, .pkgenv$ncbi_path) |> 
        purrr::map_chr(~ {
            if (is.null(.x)) {
                return(NA)
            } else {
                name <- .x |> 
                    dplyr::filter(.data$type == "scientific name") |> 
                    dplyr::pull(.data$name)
                return(name)
            }
        })
}
