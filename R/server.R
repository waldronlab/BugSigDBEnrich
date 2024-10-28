
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
    waiter::waiter_show(
        html = htmltools::tagList(
            waiter::spin_pulsar(),
            htmltools::tags$br(),
            htmltools::tags$br(),
            htmltools::div(
                class = "h4", "Loading BugSigDBEnrich data...",
                style = "color: black;"
            ),
            htmltools::div(
                class = "h5", "Please wait...",
                style = "color: black;"
            )
        ),
        color = "white"
    )
    bsdb <- bugsigdbr::importBugSigDB()
    waiter::waiter_hide()
    
    urlHandlerServer(session)
    httpGetHandler(query, session, input, output, inputSigFun, bsdb)
    
    resetApp(input, session)
    
    inputSigFun <- inputSignature(input)
    textBoxExamplesServer(input, session); fileInputExamplesServer(output)
    inputHelp(input)
    
    ## BugSigDB - Options and help
    bsdbSelectAllRanks(input, session)
    bsdbSetExact2TrueWhenMultipleRanks(input, session)
    bsdbSigOptionsHelp(input)
    
    ## Bugphyzz - Options and help
    ## TODO
    
    shiny::observeEvent(input$analyzeButton, {
        output$result_header <- renderUI({ NULL })
        output$result_table <- DT::renderDT({ data.frame() })

        if (input$options_tab == "bugsigdb_panel") {
            bsdbResult(input, output, inputSigFun, bsdb)
        } else if (input$options_tab == "bugphyzz_panel") {
            output$result_header <- shiny::renderUI({
                htmltools::div("Placeholder.")
            })
        }
    })
}
