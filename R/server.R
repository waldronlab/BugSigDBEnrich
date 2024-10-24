
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
    ## Show a waiter before BugSigDB is loaded
    waiter::waiter_show(
        html = htmltools::tagList(
            waiter::spin_pulsar(),
            htmltools::div(
                class = "h3", "Loading BugSigDBEnrich...",
                style = "color: black;"
            ),
            htmltools::div(
                class = "h4", "Please wait...",
                style = "color: black;"
            )
        ),
        color = "white"
    )
    bsdb <- bugsigdbr::importBugSigDB()
    waiter::waiter_hide()
    
    ## Reactive for input signature
    inputSigFun <- inputSignature(input)
    
    ## Examples
    textBoxExamplesServer(input, session)
    fileInputExamplesServer(output)
    
    ## Signature options
    selectAllRanks(input, session)
    setExact2TrueWhenMultipleRanks(input, session)
    
    ## Reset app
    resetApp(input, session)
    
    ## Used to handle URLs in the help boxes ("more...")
    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query$tab)) {
            shiny::updateNavbarPage(session, "navbar", selected = query$tab)
        }
    })
    
    ## Help boxes (modal)
    inputHelp(input)
    bsdbSigOptionsHelp(input)
    
    ## HTT GET
    httpGetHandler(query, session, input, output, inputSigFun, bsdb)
    
    ## Analysis
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
