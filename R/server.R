
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
    
    ## Load bsdb first
    bsdb <- bugsigdbr::importBugSigDB()
    
    ## Reactive for input signature
    inputSigFun <- inputSignature(input)
    
    ## Examples
    textBoxExamplesServer(input, session)
    fileInputExamplesServer(output)
    
    ## Signature options
    selectAllRanks(input, session)
    setExact2TrueWhenMultipleRanks(input, session)
    
    resetApp(input, session)
    
    ## HTTR GET handler
    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query$vector)) {
            prefill_vector <- strsplit(query$vector, ",")[[1]]
            shiny::updateTextInput(
                session, "text_input",
                value = paste(prefill_vector, collapse = "\n")
            )
            detectedType <- unique(whichType(prefill_vector))[1] # select only the first to prevent errors.
            shiny::updateRadioButtons(
                session = session, inputId = "type_selection",
                selected = detectedType
            )
            shiny::req(input$text_input) 
            mainResult(input, output, inputSigFun, bsdb)
        }
    })
    
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
