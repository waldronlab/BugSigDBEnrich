library(purrr)

ranks <- c(
    "superkingdom", "phylum", "class", "order", "family",
    "genus", "species", "strain"
)

getRank <- function(ids, db) {
    ranks <- rankOptions(db)
    path <- cacheTaxonomizr::txPath()
    taxonomy <- withCallingHandlers(
        warning = function(w) invokeRestart("muffleWarning"),
        expr =  taxonomizr::getRawTaxonomy(ids, path)
    )
    lgl <- !purrr::map_lgl(taxonomy, ~ all(is.na(.x)))
    purrr::map_if(
        .x = taxonomy,
        .p = lgl,
        .f = ~ {
            rks <- .x[ranks]
            rks <- rks[!is.na(rks)]
            names(rks)[length(rks)]
        }
    ) |> 
        purrr::map_chr(~ {
            if (!length(.x)) {
                return(NA)
            } else {
                return(.x)
            }
        }) |> 
        unname()
}

getTaxIDs <- function(x) {
    path <- cacheTaxonomizr::txPath()
    myIds <- withCallingHandlers(
        warning = function(w) invokeRestart("muffleWarning"),
        expr = taxonomizr::getId(x, sqlFile = path)
    )
    myIds |> 
        strsplit(",") |> 
        purrr::map_chr( ~{
            if (length(.x) > 1) {
                return(getProk(.x))
            } else {
                return(.x)
            }
        })
    return(myIds)
}

getProk <- function(x) {
    path <- cacheTaxonomizr::txPath()
    taxonomizr::getRawTaxonomy(x, path) |> 
        purrr::keep(~ {
            sk <- .x[["superkingdom"]]
            sk %in% c("Bacteria", "Archaea")
        }) |> 
        names() |> 
        stringr::str_trim()
}

nb <- exampleSigs$ncbi
# nb <- c(nb, 2010)
tx <- exampleSigs$taxname
# tx <- c("house", tx, "Bacillus")
mt <- exampleSigs$metaphlan


rs <- tx |>
    getTaxIDs() |> 
    getRank()

names(rs) <- nb

# !all(x %in% rankOptions("bugphyzz"))

purrr::imap(rs, ~ paste0(.y, " (", .x, ")")) |> 
    purrr::flatten_chr() |> 
    paste(collapse = ", ")

    