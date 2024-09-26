jacSim <- function(sig, sigL) {
    res <- purrr::map_dbl(sigL,  ~ {
        round(.jaccard_similarity(.x, sig), 2)
    })
    dat <- data.frame(signature = names(res), jaccard = unname(res))
    dplyr::arrange(dat, -.data$jaccard)
}

## Helper function for jacSim
.jaccard_similarity <- function(x, y) {
    intersection <- length(intersect(x, y))
    union <- length(union(x, y))
    return(intersection / union)
}
