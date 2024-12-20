semSim <- function(inputSig, sigs, obo) {
    if (is.null(obo())) {
        obo(BugSigDBStats::getNcbiTaxonomyObo())
    }
    inSig <- purrr::map(inputSig, ~ paste0("NCBITaxon:", .x))
    dbSigs <- purrr::map(sigs, ~ paste0("NCBITaxon:", .x))
    
    inSig <- .getValidOBOSigs(inSig, obo())
    dbSigs <- .getValidOBOSigs(dbSigs, obo())
    
    res <- ontologySimilarity::get_sim_grid(
        ontology = obo(), term_sets = inSig, term_sets2 = dbSigs
    ) |> 
        t() |> 
        as.data.frame() |> 
        tibble::rownames_to_column(var = "Signature") |> 
        purrr::set_names(c("Signature", "SemSim")) |> 
        tibble::as_tibble() |> 
        dplyr::mutate(
            SemSim = round(.data$SemSim, 2)
        )
    return(res)
}

.getValidOBOSigs <- function(sigL, obo) {
    utax <- unique(unlist(sigL, use.names = FALSE))
    nt <- utax[!(utax %in% obo$id)]
    purrr::map(sigL, ~ setdiff(.x, nt))
}