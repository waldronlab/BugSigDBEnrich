
library(bugsigdbr)

bsdb <- importBugSigDB()




dat <- bsdb[bsdb$`BSDB ID` == "bsdb:1/2/1",]

sig_mixed <- getSignatures(
    df = dat, tax.id.type = "taxname",
    tax.level = "mixed", exact.tax.level = TRUE
)
sig_gn <- getSignatures(
    df = dat, tax.id.type = "taxname",
    tax.level = "genus", exact.tax.level = TRUE
)
fam_exact_true <- getSignatures(
    df = dat, tax.id.type = "taxname",
    tax.level = "family", exact.tax.level = TRUE
)
fam_exact_false <- getSignatures(
    df = dat, tax.id.type = "taxname",
    tax.level = "kingdom", exact.tax.level = FALSE
)
sig_mixed
sig_gn
fam_exact_true
fam_exact_false

# 270497
# 990721
dat <- bsdb[bsdb$`BSDB ID` == "bsdb:22/1/1",]

sig1 <- getSignatures(
    df = dat, tax.id.type = "ncbi",
    tax.level = "mixed", exact.tax.level = TRUE
)[[1]]
sig2 <- getSignatures(
    df = dat, tax.id.type = "taxname",
    tax.level = "mixed", exact.tax.level = TRUE
)[[1]]
length(sig1)
length(sig2)


names(sig1) <- sig2
names(sig2) <- sig1


