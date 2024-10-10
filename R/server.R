
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
