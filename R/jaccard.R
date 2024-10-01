jacSim <- function(sig, sigL) {
    res <- purrr::map_dbl(sigL,  ~ {
        round(.jaccard_similarity(.x, sig), 2)
    })
    dat <- data.frame(
        bsdb_id = .getID(names(res)),
        signature = names(res),
        jaccard = unname(res)
    ) |>
        dplyr::arrange(-.data$jaccard)
}

## Helper function for jacSim
.jaccard_similarity <- function(x, y) {
    intersection <- length(intersect(x, y))
    union <- length(union(x, y))
    return(intersection / union)
}
