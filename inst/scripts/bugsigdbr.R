
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
