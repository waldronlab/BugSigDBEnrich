
.getID <- function(signame)  {
    stringr::str_extract(signame, "^bsdb:\\d+/\\d+/\\d+")
}
