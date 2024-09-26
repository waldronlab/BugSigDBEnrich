readGMT <- function(fname) {
    as.character(clusterProfiler::read.gmt(fname)$gene)
}


