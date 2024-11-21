library(ontologyIndex)
library(ontologySimilarity)
library(bugsigdbr)
library(tidyr)
library(dplyr)
library(tibble)
library(purrr)

bsdb <- importBugSigDB()

sigs <- getSignatures(bsdb, tax.level = "mixed", min.size = 5) |> 
    map(~ paste0("NCBITaxon:", .x))
sig1 <- sigs[1]

system.time(
    obo <- BugSigDBStats::getNcbiTaxonomyObo()
)

.getValidOBOSigs <- function(sigL, obo) {
    utax <- unique(unlist(sigL, use.names = FALSE))
    nt <- utax[!(utax %in% obo$id)]
    purrr::map(sigL, ~ setdiff(.x, nt))
}

inputSig <- .getValidOBOSigs(sig1, obo)
targetSigs <- .getValidOBOSigs(sigs, obo)


dat <- ontologySimilarity::get_sim_grid(
    ontology = obo, term_sets = inputSig, term_sets2 = targetSigs
) |> 
    t() |> 
    as.data.frame() |> 
    tibble::rownames_to_column(var = "Signature") |> 
    purrr::set_names(c("Signature", "SemSim")) |> 
    tibble::as_tibble() |> 
    dplyr::mutate(
        SemSim = round(.data$SemSim, 2)
    )
    # dplyr::pull(.data$SemSim)


semSim(list(inputSig = paste0("NCBITaxon:", exampleSigs$ncbi)), sigs)
