# .pkgenv <- new.env(parent = emptyenv())
# 
# .onLoad <- function(libname, pkgname) {
#     .pkgenv$bsdb <- bugsigdbr::importBugSigDB()
#     .pkgenv$b <- bugphyzz::importBugphyzz()
# }