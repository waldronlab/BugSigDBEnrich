# .get_cache <- function() {
#     cache <- tools::R_user_dir("BugSigDBEnrich", which="cache")
#     BiocFileCache::BiocFileCache(cache)
# }
# 
# .ncbiPath <- function() {
#     bfc <- .get_cache()
#     rid <- BiocFileCache::bfcquery(
#         x = bfc, query = "nameNode.sqlite", field = "rname"
#     )$rid
#     if (!length(rid)) {
#         tmp_dir <- tempdir()
#         tmp_file <- file.path(tmp_dir, "nameNode.sqlite")
#         taxonomizr::prepareDatabase(
#             sqlFile = tmp_file,
#             tmpDir = tmp_dir,
#             getAccessions = FALSE
#         )
#         path <- BiocFileCache::bfcadd(
#             x = bfc, rname = "nameNode.sqlite", rtype = "local", action = "move",
#             fpath = tmp_file
#         )
#     } else {
#         path <- BiocFileCache::bfcinfo(x = bfc, rids = rid)$rpath
#     }
#     return(path)
# }

