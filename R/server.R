
#' Create server
#'
#' @param input Input shiny.
#' @param output Output shiny.
#' @param session Session shiny.
#' 
#' @importFrom rlang .data 
#'
#' @return A shinyApp
#'
server <- function(input, output, session) {
    
    bsdb <- bugsigdbr::importBugSigDB()
    
    ## Examples
    textBoxExamplesServer(input, session)
    fileInputExamplesServer(output)
    
    ## Handle query
    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query$vector)) {
            prefill_vector <- strsplit(query$vector, ",")[[1]]
            shiny::updateTextInput(
                session, "text_input",
                value = paste(prefill_vector, collapse = "\n")
            )
        }
    })
    
    inputSigFun <- inputSignature(input) # Create reactive (called in mainResult)
    
    ## (De)select all button
    selectAllRanks(input, session)
    
    resetApp(input, session)
    
    shiny::observeEvent(input$analyzeButton, {
        if (!length(input$rank_selection)) {
            shiny::showNotification(
                "Please select at least one rank option.", 
                type = "error"
            )
        } else {
            mainResult(input, output, inputSigFun, bsdb)
        }  
    })
}
