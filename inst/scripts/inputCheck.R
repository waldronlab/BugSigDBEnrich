library(purrr)

getRank <- function(ids) {
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


nb <- exampleSigs$ncbi
nb <- c(nb, 2010)
tx <- exampleSigs$taxname
tx <- c("house", tx, "Bacillus")
mt <- exampleSigs$metaphlan


nb |> 
    getRank()

tx |> 
    getTaxIDs() 

tx |> 
    getTaxIDs() |> 
    getRank()

