
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
    
    df <- NULL
    sigs <- NULL
    resultHeader <- NULL
    inputSig <- NULL
    
    open_tabs <- shiny::reactiveVal(list())
    
    shiny::observeEvent(input$analyzeButton, {
        
        output$result_header <- renderUI(NULL)
        output$result_table <- DT::renderDT(NULL) 
        
        tabs_to_remove <- names(open_tabs())
        for (tab_name in tabs_to_remove) {
            shiny::removeTab(inputId = "main_tabs", target = tab_name)
        }
        
       open_tabs(list()) 
        
        # Keep removing the current tab until none are left
        # while(!is.null(current_tabs)) {
        #     removeTab(inputId = "main_tabs", target = current_tabs)
        #     current_tabs <- input$main_tabs
        # }
        
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        
        if (cond1) {
            inputSig <<- unlist(strsplit(input$text_input, "\n"))
            inputSig <<- inputSig[inputSig != ""]
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
            res <- bsdbResult(input, output, inputSig, bsdb)
        } else if (input$options_tab == "bugphyzz_panel") {
            bugphyzzResult(input, output, inputSig, b)
        }
        
        
       df <<- res$df
       sigs <<-  res$sigs
       resultHeader <<- res$resultHeader
       
       
       output$result_header <- shiny::renderUI({shiny::markdown(resultHeader)})
       
       output$result_table <- DT::renderDT({
           dfDisplay <- df |> 
               dplyr::mutate(
                   Study = stringr::str_c(
                       '<a href="https://bugsigdb.org/Study_', .data$Study,
                       '" target="_blank">', .data$Study, '</a>'
                   ),
                   Signature = stringr::str_c(
                       '<a href="javascript:void(0);" class="signature-link" id="signature_',
                       dplyr::row_number(), '">', .data$Signature, '</a>' 
                   )
               ) |>
               dplyr::select(-.data$bsdb_id)
           tag_list <- getColNameTags(dfDisplay)
           dt <- DT::datatable(
               dfDisplay,
               rownames = FALSE,
               escape = FALSE,
               selection = "none",
               container = htmltools::withTags(
                   htmltools::tags$table(
                       class = 'display',
                       htmltools::tags$thead(htmltools::tags$tr(tag_list))
                   )
               ),
               options = list(
                   headerCallback = DT::JS("function(thead, data, start, end, display) {
                $(thead).find('th').css('text-align', 'center');
            }")
               )
           )
           dt$dependencies <- appendDTDeps(dt)
           dt
       })
       
       output$downloadData <- shiny::downloadHandler(
           filename = function() {
               paste("BugSigDBEnrich-bsdb-", Sys.Date(), ".tsv", sep = "")
           },
           content = function(file) {
               utils::write.table(
                   x = df, file, row.names = FALSE,
                   sep = "\t"
               )
           }
       )
    })
    
    shiny::observeEvent(input$clicked_signature, {
        # print(head(df))
        clicked_id <- input$clicked_signature
        row_id <- as.numeric(sub("signature_", "", clicked_id))
        tab_title <- stringr::str_extract(
            df$Signature[row_id], "bsdb:\\d+/\\d+/\\d+"
        ) |> 
            stringr::str_replace_all("/", "_") |> 
            stringr::str_replace(":", "_")
        
        current_tabs <- open_tabs()
        
        
        if (!(tab_title %in% names(current_tabs))) {
        
        sigsTable <- sets2Df(inputSig, sigs[[df$Signature[row_id]]])
        # print(head(sigsTable))
        tbl <- sigsTable |> 
            dplyr::mutate(
                Label = factor(Label, levels = c(
                    "Only in input", "Intersect", "Only in target"
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
                        selection = "none",
                        filter = "top"
                    )
                }),
            )
        )
        shiny::appendTab(inputId = "main_tabs", new_tab, select = TRUE)
        current_tabs[[tab_title]] <- TRUE
        open_tabs(current_tabs)
        }
    })
    
    shiny::observeEvent(input$close_tab, {
        tab_id <- input$close_tab
        current_tabs <- open_tabs()
        current_tabs[[tab_id]] <- NULL
        open_tabs(current_tabs)
        shiny::removeTab(inputId = "main_tabs", target = tab_id)
    })
    
}
