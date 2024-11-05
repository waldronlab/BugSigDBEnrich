sets2Df <- function(x, y) {
    input_only <- setdiff(x, y)
    both <- intersect(x, y)
    target_only <- setdiff(y, x)
    ids <- c(input_only, both, target_only)
    labels <- dplyr::case_when(
        ids %in% input_only ~ "Only in input",
        ids %in% both ~ "Intersect",
        ids %in% target_only ~ "Only in target"
    )
    data.frame(
        ID = ids,
        Label = labels
    )
}