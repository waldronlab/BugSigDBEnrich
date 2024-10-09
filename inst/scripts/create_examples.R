library(bugsigdbr)

bsdb <- importBugSigDB(version = "10.5281/zenodo.10627578")

exampleSig <- "bsdb:855/1/2_Dry-eye-syndrome:Dry-Eye-Disease-patients_vs_Healthy-Controls_DOWN"
idTypes <- c("ncbi", "taxname", "metaphlan")
names(idTypes) <- idTypes

exampleSigs <- lapply(idTypes,  function(x) {
    sigs <- getSignatures(
        df = bsdb, tax.id.type = x, tax.level = "genus",
        exact.tax.level = TRUE, min.size = 5
    )
    sigs[exampleSig][[1]]
})

for (i in seq_along(exampleSigs)) {
    fname <- paste0(names(exampleSigs)[i], ".txt")
    fpath <- file.path("inst", "extdata", fname)
    writeLines(exampleSigs[[i]], con = fpath)
}

usethis::use_data(
    exampleSigs, internal = TRUE, overwrite = TRUE
)
