#' Calculate jaccard similarity
#' @importFrom rlang .data 
#' @param sig Input signature.
#' @param sigL  List of BugSigDB signatures
#'
#' @return A data.frame
#'
simFun <- function(sig, sigL) {
    ji <- purrr::map_dbl(sigL,  ~ {
        round(.jaccard_similarity(.x, sig), 2)
    })
    oc <- purrr::map_dbl(sigL,  ~ {
        round(.overlap_coefficient(.x, sig), 2)
    })
    data.frame(
        bsdb_id = .getBsdbId(names(ji)),
        Signature = names(ji),
        JI = unname(ji),
        OC = unname(oc),
        Size = purrr::map_int(sigL, length)
    ) |>
        dplyr::arrange(-.data[["JI"]], -.data[["OC"]])
}

## Helper function for jacSim
.jaccard_similarity <- function(x, y) {
    intersection <- length(intersect(x, y))
    union <- length(union(x, y))
    intersection / union
}

.overlap_coefficient <- function(A, B) {
    intersection <- length(intersect(A, B))
    min_size <- min(length(A), length(B))
    intersection / min_size
}

.getBsdbId <- function(signame)  {
    stringr::str_extract(signame, "^bsdb:\\d+/\\d+/\\d+")
}
