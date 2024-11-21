
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
    
    # urlHandlerServer(session)
    
    resetApp(input, session)
    
    textBoxExamplesServer(input, session); fileInputExamplesServer(output)
    inputHelp(input)
    
    bsdbSigOptionsServer(input, session)
    bsdbSigOptionsHelp(input)
    
    bugphyzzOptionsServer(input, session, b)
    bugphyzzOptionsHelp(input)
    
    shiny::observeEvent(input$semantic_help, {
        helpModal(
            "Semantic similarity",
            stringr::str_c(
                "Only available when the input is of type ncbi. ",
                helpPageDiv("More...", "options")
                # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
            )
        )
    })
    
    inputSigFun <- inputSignature(input)
    
    dat <- shiny::reactiveVal(data.frame())
    open_tabs <- shiny::reactiveVal(list())
    sigs_rval <- shiny::reactiveVal(list())
    
    httpGetHandler(
        query, session, input, output, inputSigFun, bsdb, b, dat, open_tabs, sigs_rval
    )
    
    shiny::observeEvent(input$analyzeButton, {
        
        output$result_header <- shiny::renderUI(NULL)
        output$res <- shiny::renderUI(NULL)
        
        output$res <-  shiny::renderUI({
            shiny::tabsetPanel(
                id = "main_tabs",
                shiny::tabPanel(
                    title = "Table",
                    htmltools::div(
                        id = "table-container",
                        DT::DTOutput("result_table")
                    )
                )
            )
        })
        
        ## Clean reactive values -- Not needed for inputSigFun
        dat(data.frame())
        open_tabs(list())
        sigs_rval(list())
        
        waiter::waiter_show(
            html = htmltools::tagList(
                waiter::spin_timer(),
                htmltools::tags$br(),
                htmltools::tags$br(),
                htmltools::div(
                    class = "h4", "Analyzing...",
                    style = "color: black;"
                ),
                htmltools::div(
                    class = "h5", "Please wait...",
                    style = "color: black;"
                )
            ),
            color = "white"
        )
        if (input$options_tab == "bugsigdb_panel") {
            bsdbResult(input, output, inputSigFun, bsdb, dat, sigs_rval)
        } else if (input$options_tab == "bugphyzz_panel") {
            bugphyzzResult(input, output, inputSigFun, b, dat, sigs_rval)
        }
        waiter::waiter_hide()
    })
    
    ## Open signature tabs
    shiny::observeEvent(input$clicked_signature, {
        clicked_id <- input$clicked_signature
        row_id <- as.numeric(sub("signature_", "", clicked_id))
        
        bsdb_rgx <- "^bsdb:\\d+/\\d+/\\d+"
        is_bsdb <- grepl(bsdb_rgx, dat()$Signature[row_id])
        
        if (is_bsdb) {
            tab_title <- stringr::str_extract(
                dat()$Signature[row_id], bsdb_rgx
            ) |> 
                stringr::str_replace_all("/", "_") |> 
                stringr::str_replace(":", "_")
        } else {
           tab_title <- make.names(dat()$Signature[row_id])
        }
        
        current_tabs <- open_tabs()
        
        if (!(tab_title %in% names(current_tabs))) {
            waiter::waiter_show(
                html = htmltools::tagList(
                    waiter::spin_timer(),
                    htmltools::tags$br(),
                    htmltools::tags$br(),
                    htmltools::div(
                        class = "h4", "Getting taxonomy information...",
                        style = "color: black;"
                    ),
                    htmltools::div(
                        class = "h5", "Please wait...",
                        style = "color: black;"
                    )
                ),
                color = "white"
            )
            sigsTable <- sets2Df(inputSigFun, sigs_rval()[[dat()$Signature[row_id]]], input)
            waiter::waiter_hide()
            
            tbl <- sigsTable |> 
                dplyr::mutate(
                    Label = factor(Label, levels = c(
                        "Input only", "Both", "Database only"
                    ))
                ) |> 
                dplyr::count(Label, .drop = FALSE)
            counts <- tbl$n
            names(counts) <- tbl$Label
            
            summaryText <- vector("character", length(counts))
            for (i in seq_along(summaryText)) {
                txt <- paste0(names(counts)[i], ": ", counts[i])
                summaryText[i] <- txt
            }
            summaryText <- paste(summaryText, collapse = ", ")
            
            new_tab <- shiny::tabPanel(
                title = htmltools::span(
                    tab_title,
                    htmltools::span("×", class = "close-tab")
                ),
                value = tab_title,
                htmltools::tagList(
                    htmltools::p(summaryText),
                    DT::renderDT({
                        DT::datatable(
                            data = sigsTable, rownames = FALSE, escape = FALSE,
                            selection = "none"
                            # filter = "top"
                        )
                    }),
                )
            )
            shiny::appendTab(inputId = "main_tabs", new_tab, select = TRUE)
            current_tabs[[tab_title]] <- TRUE
            open_tabs(current_tabs)
        }
    })
    
    ## Close signature tabs
    shiny::observeEvent(input$close_tab, {
        tab_id <- input$close_tab
        current_tabs <- open_tabs()
        current_tabs[[tab_id]] <- NULL
        open_tabs(current_tabs)
        shiny::removeTab(inputId = "main_tabs", target = tab_id)
    })
}


resetApp <- function(input, session) {
    shiny::observeEvent(input$resetButton, {
        session$sendCustomMessage("resetURL", list())
        session$reload()
    })
}
# tabs_to_remove <- names(open_tabs())
# for (tab_name in tabs_to_remove) {
#     shiny::removeTab(inputId = "main_tabs", target = tab_name)
# }
