
actionButtons <- function() {
    list(
        shiny::actionButton(
            inputId = "analyzeButton", 
            label = "Analyze",
            icon = shiny::icon("magnifying-glass-chart")
        ),
        shiny::downloadButton(
            outputId = "downloadData",
            label = "Download result"
        ),
        shiny::actionButton(
            inputId = "resetButton", 
            label = "Reset app",
            icon = shiny::icon("refresh"),
            class = "btn-red" 
        )
    )
}
