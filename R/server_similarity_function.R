#' Calculate jaccard similarity
#' @importFrom rlang .data 
#' @param sig Input signature.
#' @param sigL  List of BugSigDB signatures
#' @param opt "bsdb"  or "bugphyzz"
#' @param input shiny input variable
#'
#' @return A data.frame
#'
simFun <- function(sig, sigL, opt = NULL, input, obo) {
    
    ji <- purrr::map_dbl(sigL,  ~ {
        round(.jaccard_similarity(.x, sig), 2)
    })
    oc <- purrr::map_dbl(sigL,  ~ {
        round(.overlap_coefficient(.x, sig), 2)
    })
    
    ## Var names corpus and doc are from the bm_25 func args
    corpus <- sigL |> 
        purrr::map(~ paste0(.x, collapse = " ")) |> 
        purrr::flatten_chr()
    names(corpus) <- names(sigL)
    doc <- paste0(sig, collapse = " ")
    bm25 <- superml::bm_25(doc, corpus, top_n = length(corpus))
    bm25 <- bm25[match(corpus, names(bm25))]
    bm25 <- round(bm25, 2)
    
    df <- data.frame(
        Signature = names(ji),
        BM25 = bm25,
        JI = unname(ji),
        OC = unname(oc),
        OCPer = get_per(oc),
        Size = purrr::map_int(sigL, length)
    ) |>
        dplyr::arrange(-.data[["BM25"]], -.data[["OC"]], -.data[["JI"]])
    
    if (!is.null(opt)) {
        if (opt == "bsdb") {
            df <- df |> 
                dplyr::mutate(
                    bsdb_id = .getBsdbId(.data$Signature)
                ) |> 
                dplyr::relocate(.data$bsdb_id)
        }
    }
    
    if (input$semantic) {
        semantic_similarity <- semSim(list(inputSig = sig), sigL, obo)
        df <- dplyr::left_join(df, semantic_similarity, by = "Signature")
    }
    
    return(df)
}

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
