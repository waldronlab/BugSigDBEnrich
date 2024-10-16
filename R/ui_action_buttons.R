
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

cleanURLWhenResetApp <- function() {
    htmltools::tags$script(
        "
    Shiny.addCustomMessageHandler('resetURL', function(message) {
      // Get the current app path without the query string
      var appPath = window.location.pathname;

      // Check if the app is running on localhost (ignore the port)
      if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        // Keep the path as it is for local environment
        window.history.replaceState({}, document.title, '/');
      } else {
        // For server environment, reset only to the app path
        window.history.replaceState({}, document.title, 'https://shiny.sph.cuny.edu/BugSigDBEnrich/');
      }
    });
    "
    )
}
