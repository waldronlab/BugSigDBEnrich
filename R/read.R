readGMT <- function(fname) {
    as.character(clusterProfiler::read.gmt(fname)$gene)
}

readBox <- function(text_input) {
    char_vec <- unlist(strsplit(text_input, "\n"))
    char_vec <- char_vec[char_vec != ""]
}


