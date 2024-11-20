
bsdb <- bugsigdbr::importBugSigDB()
sigs <- bugsigdbr::getSignatures(bsdb, min.size = 5, exact.tax.level = TRUE)
sigsComb <- utils::combn(sigs, 2, simplify = FALSE)
system.time({
    ovs <- purrr::map_dbl(sigsComb, ~ {
        BugSigDBEnrich:::.overlap_coefficient(.x[[1]], .x[[2]])
    })
    
})




hist(ovs)

ovs <- ovs[ovs > 0]
hist(ovs)

qs <- quantile(ovs, probs = seq(0, 1, 0.01))
qs

ecdf_dist(0.4)

names(qs)[max(which((0.1 >= qs)))]

x <- bsdb |> 
    filter(Condition == "Colorectal cancer") |> 
    bugsigdbr::getSignatures(min.size = 5, exact.tax.level = TRUE, tax.level = "genus")
x <- x[names(sort(map_int(x, length), decreasing = TRUE))]

