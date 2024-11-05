sets2Df <- function(x, y) {
    # print(head(x))
    # print(head(y))
    input_only <- setdiff(x, y)
    both <- intersect(x, y)
    target_only <- setdiff(y, x)
    ids <- c(input_only, both, target_only)
    names(x) <- x
    print(head(x))
    ids2 <- c(
        names(x[input_only]),
        names(y)[match(both, y)],
        names(y)[match(target_only, y)]
    )
    message(length(ids))
    message(length(ids2))
    labels <- dplyr::case_when(
        ids %in% input_only ~ "Only in input",
        ids %in% both ~ "Intersect",
        ids %in% target_only ~ "Only in target"
    )
    data.frame(
        ID = ids,
        ID2 = ids2,
        Label = labels
    )
}