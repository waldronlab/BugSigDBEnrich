
.getBsdbId <- function(signame)  {
    stringr::str_extract(signame, "^bsdb:\\d+/\\d+/\\d+")
}

appSubtitle <- function() {
    htmltools::HTML(stringr::str_c(
        "Run enrichment and similarity analyses against ",
        '<a href="https://bugsigdb.org" target="_blank">BugSigDB</a>',
        " signatures"
    ))
}