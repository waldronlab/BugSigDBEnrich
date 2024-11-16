
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
    
    textBoxExamplesServer(input, session); fileInputExamplesServer(output)
    inputHelp(input)
    
    bsdbSigOptionsServer(input, session)
    bsdbSigOptionsHelp(input)
    
    bugphyzzOptionsServer(input, session, b)
    bugphyzzOptionsHelp(input)
    
    shiny::observeEvent(input$analyzeButton, {
        
        output$result_header <- renderUI({ NULL })
        output$result_table <- DT::renderDT({ data.frame() })
        open_tabs <- NULL
        open_tabs <- shiny::reactiveVal(list())
        
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        
        if (cond1) {
            inputSig <- unlist(strsplit(input$text_input, "\n"))
            inputSig <- inputSig[inputSig != ""]
        } else if (cond2) {
            inputSig <- switch(
                tools::file_ext(input$file_input$name),
                txt = readLines(con = input$file_input$datapath),
                shiny::validate("Invalid file; Please upload a .txt file")
            )
        } else {
            shiny::showNotification("No input", type = "error")
            shiny::req(FALSE)
        }
        
        if (input$options_tab == "bugsigdb_panel") {
            bsdbResult(input, output, inputSig, bsdb, session, open_tabs)
        } else if (input$options_tab == "bugphyzz_panel") {
            bugphyzzResult(input, output, inputSig, b)
        }
    })
}
