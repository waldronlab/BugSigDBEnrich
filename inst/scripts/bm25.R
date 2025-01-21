
## Implementation of TF-IDF weight scores and BM25 ranking
library(bugsigdbr)
library(purrr)
library(dplyr)
library(superml)
library(ggplot2)
# library(OmicsMarkeR)

.bm25 <- function(doc, corp) {
    res <- bm_25(document = exSig, corpus = sigs, top_n = 2)
}

bsdb <- importBugSigDB()
sigsL <- getSignatures(bsdb, min.size = 5)

sigs <- sigsL |> 
    map(~ paste0(.x, collapse = " ")) |> 
    flatten_chr()
names(sigs) <- names(sigsL)

exSig <- sigs[[grep("bsdb:454/1/1", names(sigs))]]

tim <- system.time({
    res <- bm_25(document = exSig, corpus = sigs, top_n = 2)
})
tim

x <- sigs[match(names(res), sigs)]



x <- res[match(sigs, names(res))]
names(x) <- names(sigs)

class(x)

tbl <- tibble(
    SigName = names(sigs),
    BM25 = unname(res),
    Sig = map(unname(sigs), ~ strsplit(.x, " ")[[1]])
)


res[match(names(res), sigs)]


match()

# map(unname(sigs), ~ strsplit(.x, " ")[[1]])[1]

# 
# length(res)
# length(sigs)
# names(res)
# 
# hist(res)
# 
# head(res)
# 
# match(sigs, names(res))
# 
# 
# all(names(res) == sigs)


# Flatten lists to get unique elements
# all_elements <- unique(unlist(lists))

# Compute Document Frequency (DF)
# df <- sapply(all_elements, function(e) sum(sapply(lists, function(L) e %in% L)))

# Number of lists (N)
# N <- length(lists)

# Compute Inverse Document Frequency (IDF)
# idf <- log((N - df + 0.5) / (df + 0.5) + 1)

# Parameters for BM25
# k1 <- 1.5
# b <- 0.75
# avg_len <- mean(sapply(lists, length))

# Function to compute BM25 for a list
# bm25_score <- function(list_elements) {
#     tf <- table(list_elements)
#     len <- length(list_elements)
#     sapply(all_elements, function(e) {
#         f <- ifelse(e %in% names(tf), tf[e], 0)
#         idf[e] * ((f * (k1 + 1)) / (f + k1 * (1 - b + b * len / avg_len)))
#     })
# }

# Compute BM25 scores for each list
# bm25_scores <- lapply(lists, bm25_score)

# Print BM25 scores
# bm25_scores

# superml -----------------------------------------------------------------
