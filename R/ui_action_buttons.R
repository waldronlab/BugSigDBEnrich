
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
        ),
        htmltools::tags$script("
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
        ")
    )
}
