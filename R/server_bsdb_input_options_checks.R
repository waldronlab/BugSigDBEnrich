bsdbInputOptionsChecks <- function(input, inputSig) {
    if (!length(input$bsdb_rank)) {
        shiny::showNotification(
            "Please select at least one rank option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
}