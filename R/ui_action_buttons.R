        
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
        icon = shiny::icon("refresh"),
        class = "btn-red" 
    )
}

resetButtonRedCSS <- function() {
    htmltools::tags$style(htmltools::HTML("
    .btn-red {
      background-color: red;
      color: white;
    }
  "))
}