library(bugsigdbr)
library(purrr)

## Create examole sigantures
bsdb <- importBugSigDB(version = "10.5281/zenodo.10627578")

exampleSig <- "bsdb:454/1/1_Colorectal-cancer:colorectal-cancer-(CRC)_vs_healthy-controls_UP"
idTypes <- c("ncbi", "taxname", "metaphlan")
names(idTypes) <- idTypes

exampleSigs <- lapply(idTypes,  function(x) {
    sigs <- getSignatures(
        df = bsdb, tax.id.type = x, tax.level = "mixed",
        exact.tax.level = TRUE, min.size = 5
    )
    sigs[exampleSig][[1]]
})

exampleSigs[["badsig"]] <- c(
    exampleSigs$ncbi[1:3],
    exampleSigs$taxname[1:3],
    exampleSigs$metaphlan[1:3]
)

for (i in seq_along(exampleSigs)) {
    fname <- paste0(names(exampleSigs)[i], ".txt")
    fpath <- file.path("inst", "extdata", fname)
    writeLines(exampleSigs[[i]], con = fpath)
}

sigs <- bugsigdbr::getSignatures(bsdb, min.size = 5, exact.tax.level = TRUE)
sigsComb <- utils::combn(sigs, 2, simplify = FALSE)
system.time({
    ocs <- purrr::map_dbl(sigsComb, ~ {
        BugSigDBEnrich:::.overlap_coefficient(.x[[1]], .x[[2]])
    })
    
})

ocs <- ocs[ocs > 0]
per <- quantile(ocs, probs = seq(0, 1, 0.01))
# ecdf_ocs <- stats::ecdf(per)

# library(ggplot2)
# p <- data.frame(x = per) |> 
#     ggplot(aes(x)) +
#     geom_histogram(
#         fill = "dodgerblue3", color = "white", binwidth = 0.05
#     ) +
#     labs(
#         x = "Percentile", y = "Count of overlapping coefficient scores"
#     ) +
#     theme_bw()
# ggsave(
#     filename = "../www/per_plot.png", plot = p
# )

usethis::use_data(
    exampleSigs, ocs, per,
    internal = TRUE, overwrite = TRUE
)
