
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
    
    urlHandlerServer(session)
    httpGetHandler(query, session, input, output, inputSigFun, bsdb)
    
    resetApp(input, session)
    
    inputSigFun <- inputSignature(input)
    textBoxExamplesServer(input, session); fileInputExamplesServer(output)
    inputHelp(input)
    
    bsdbSigOptionsServer(input, session)
    bsdbSigOptionsHelp(input)
    
    bugphyzzOptionsServer(input, session, b)
    bugphyzzOptionsHelp(input)
    
    open_tabs <- shiny::reactiveVal(list())
    
    shiny::observeEvent(input$analyzeButton, {
        output$result_header <- renderUI({ NULL })
        output$result_table <- DT::renderDT({ data.frame() })
        
        if (input$options_tab == "bugsigdb_panel") {
            bsdbResult(input, output, inputSigFun, bsdb, session, open_tabs)
        } else if (input$options_tab == "bugphyzz_panel") {
            bugphyzzResult(input, output, inputSigFun, b)
        }
    })
}
