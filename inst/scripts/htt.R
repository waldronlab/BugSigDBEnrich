vct_chr <- BugSigDBEnrich:::generateExampleText("ncbi") |> 
    strsplit("\n") |> 
    unlist()
# print(vct_chr)
vct_chr_str <- paste(vct_chr, collapse = ",")
encoded_vct_chr_str <- utils::URLencode(vct_chr_str)
shiny_url <- paste0("http://127.0.0.1:6048?vector=", encoded_vct_chr_str)

openInShiny <- function(vct_chr) {
    vct_chr_str <- paste(vct_chr, collapse = ",")
    encoded_vct_chr_str <- utils::URLencode(vct_chr_str)
    shiny_url <- paste0(
        "https://shiny.sph.cuny.edu/BugSigDBEnrich/?vector=",
        encoded_vct_chr_str
    )
    utils::browseURL(shiny_url)
}