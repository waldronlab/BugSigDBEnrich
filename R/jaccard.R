#' Calculate jaccard similarity
#' @importFrom rlang .data 
#' @param sig Input signature.
#' @param sigL  List of BugSigDB signatures
#'
#' @return A data.frame
#'
jacSim <- function(sig, sigL) {
    res <- purrr::map_dbl(sigL,  ~ {
        round(.jaccard_similarity(.x, sig), 2)
    })
    dat <- data.frame(
        bsdb_id = .getID(names(res)),
        Signature = names(res),
        JI = unname(res)
    ) |>
        dplyr::arrange(-.data[["JI"]])
}

## Helper function for jacSim
.jaccard_similarity <- function(x, y) {
    intersection <- length(intersect(x, y))
    union <- length(union(x, y))
    intersection / union
}
