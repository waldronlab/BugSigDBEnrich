
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
    # bsdb <- .pkgenv$bsdb
    # b <- .pkgenv$b
    # ncbi_path <- .pkgenv$ncbi_path
    # message(ncbi_path)
    bsdb <- bugsigdbr::importBugSigDB()
    b <- bugphyzz::importBugphyzz()
    waiter::waiter_hide()
    
    inputSigFun <- inputSignature(input)
    
    urlHandlerServer(session)
    httpGetHandler(query, session, input, output, inputSigFun, bsdb)
    
    resetApp(input, session)
    
    textBoxExamplesServer(input, session); fileInputExamplesServer(output)
    inputHelp(input)
    
    bsdbSigOptionsServer(input, session)
    bsdbSigOptionsHelp(input)
    
    bugphyzzOptionsServer(input, session, b)
    bugphyzzOptionsHelp(input)
    
    open_tabs <- shiny::reactiveVal(list())
    
    shiny::observeEvent(input$analyzeButton, {
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        if (isFALSE(cond1) & isFALSE(cond2)) {
            shiny::showNotification(
                "No input",
                type = "error"
            )
            shiny::req(FALSE)
        }
        output$result_header <- renderUI({ NULL })
        output$result_table <- DT::renderDT({ data.frame() })
        if (input$options_tab == "bugsigdb_panel") {
            bsdbResult(input, output, inputSigFun, bsdb, session, open_tabs)
        } else if (input$options_tab == "bugphyzz_panel") {
            bugphyzzResult(input, output, inputSigFun, b)
        }
    })
}

inputSignature <- function(input) {
    ## TODO reactivity is not needed. Eliminate reactive
    shiny::reactive({
        ## This could be a different check activated with action button (maybe).
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        if (isFALSE(cond1) & isFALSE(cond2)) {
            shiny::showNotification(
                "No input",
                type = "error"
            )
        }
        shiny::req(cond1 | cond2)
        if (cond1) {
            return(readBox(input$text_input))
        } else if (cond2) {
            ext <- tools::file_ext(input$file_input$name)
            return(switch(ext,
                          txt = readLines(con = input$file_input$datapath),
                          shiny::validate("Invalid file; Please upload a .txt file")
            ))
        }
    })
}

readBox <- function(text_input) {
    char_vec <- unlist(strsplit(text_input, "\n"))
    char_vec <- char_vec[char_vec != ""]
}
