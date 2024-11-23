

s <- exampleSigs$ncbi


tx_path <- cacheTaxonomizr::txPath()

taxonomizr::getTaxonomy("562", sqlFile = tx_path)

taxonomizr::getCommon("562", sqlFile = tx_path, types = "scientific name")
x <- taxonomizr::getId("Bacillus", sqlFile = tx_path) |> 
    strsplit(",") |> 
    unlist()
    
