
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
                class = "h4", "Loading...",
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
    b <- bugphyzz::importBugphyzz()
    waiter::waiter_hide()
    
    # shiny::observe({
    #     shiny::updateSelectInput(
    #         session = session,
    #         inputId = "bugphyzz_attributes",
    #         choices =  c("select all", names(b))
    #     )
    # })
    # shiny::observeEvent(input$bugphyzz_attributes, {
    #     if ("select all" %in% input$bugphyzz_attributes) {
    #         shiny::updateSelectizeInput(
    #             session = session,
    #             inputId = "bugphyzz_attributes",
    #             selected = names(b)
    #         )
    #     }
    # })
    
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
    bugphyzzAttributes(input, session, b)
    bugphyzzOptionsHelp(input)
    
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
