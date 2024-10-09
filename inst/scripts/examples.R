library(bugsigdbr)
library(purrr)
bsdb <- importBugSigDB()
sigs <- getSignatures(
    bsdb,
    tax.id.type = "ncbi", tax.level = "genus", exact.tax.level = TRUE,
    min.size = 5
)

sig_name <- names(sort(map_int(sigs, length), decreasing = TRUE))[2]

writeGMT(
    sigs = sigs[sig_name],
    gmt.file = "~/Projects/BugSigDBShiny/inst/extdata/sigGn.gmt"
)

fname <- system.file(
    "extdata", "sigGn.gmt", package = "BugSigDBShiny",
    mustWork = TRUE
)

x <- as.character(clusterProfiler::read.gmt(fname)$gene)

proxy::dist(x = x, y = x, method = "Jaccard")

.jaccard_similarity(x, sigs[[1]])

map_dbl(sigs, ~ {
    .jaccard_similarity(x, .x)
})

res <- jacSim(x, sigs)
