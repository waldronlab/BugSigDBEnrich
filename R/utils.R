appendHelp <- function(x) {
    linkName <- paste0("col_", x, "_help_link")
    htmltools::tagList(
        x,
        htmltools::tags$a(
            href = "#",
            class = "column-help",
            `data-column` = x,
            "?",
            style = "margin-left: 5px; color: blue; text-decoration: none; font-weight: bold;"
        )
    )
}

