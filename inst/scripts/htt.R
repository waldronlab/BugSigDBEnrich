baseURL <- "http://127.0.0.1:4817/" 

x <- BugSigDBEnrich:::generateExampleText("ncbi") |> 
    strsplit("\n") |> 
    unlist() |> 
    head()
y <- BugSigDBEnrich:::generateExampleText("taxname") |> 
    strsplit("\n") |> 
    unlist() |> 
    head()
z <- BugSigDBEnrich:::generateExampleText("metaphlan") |> 
    strsplit("\n") |> 
    unlist() |> 
    head()
openInShiny <- function(vct_chr, baseUrl) {
    vct_chr_str <- paste(vct_chr, collapse = ",")
    encoded_vct_chr_str <- utils::URLencode(vct_chr_str)
    shiny_url <- paste0(baseURL, "?vector=", encoded_vct_chr_str)
    utils::browseURL(shiny_url)
}
openInShiny(x, baseURL)
openInShiny(y, baseURL)
openInShiny(z, baseURL)