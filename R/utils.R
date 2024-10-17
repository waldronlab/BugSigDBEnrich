appendHelp <- function(colName) {
    htmltools::tagList(
        colName,
        htmltools::tags$a(
            href = "#",
            class = "column-help",
            `data-column` = colName,
            "?",
            style = "margin-left: 5px; color: blue; text-decoration: none; font-weight: bold;"
        )
    )
}
