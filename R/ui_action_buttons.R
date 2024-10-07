        
analyzeButton <- function() {
    shiny::actionButton(
        inputId = "analyzeButton", 
        label = "Analyze",
        icon = shiny::icon("table")
    )
}

downloadResultButton <- function() {
    shiny::downloadButton(
        outputId = "downloadData",
        label = "Download result"
    )
}

resetButton <- function() {
    shiny::actionButton(
        inputId = "resetButton", 
        label = "Reset app",
        icon = shiny::icon("refresh")
    )
}
