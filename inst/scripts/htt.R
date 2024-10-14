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
openInShiny <- function(vct_chr) {
    vct_chr_str <- paste(vct_chr, collapse = ",")
    encoded_vct_chr_str <- utils::URLencode(vct_chr_str)
    shiny_url <- paste0(
        "https://shiny.sph.cuny.edu/BugSigDBEnrich/?vector=",
        encoded_vct_chr_str
    )
    # return(shiny_url)
    utils::browseURL(shiny_url)
}
openInShiny(x)
openInShiny(y)
openInShiny(z)