
mainResult <- function(input, output, inputSigFun, bsdb) {
    ## Analysis #######################################################
    inputSig <- inputSigFun()
    
    vct_lgl <- isType(inputSig, input$type_selection)
    
    if (isFALSE(all(vct_lgl))) {
        shiny::showNotification(
            stringr::str_c(
                sum(vct_lgl == FALSE), " of ", length(vct_lgl),
                " identifiers are inconsistent. Please review their format."
            ),
            type = "warning"
            
        )
    }
    
    bsdbSub <- bsdb[,c("BSDB ID", "Study"), drop = FALSE]
    sigs <- bugsigdbr::getSignatures(
        df = bsdb,
        tax.id.type = input$type_selection,
        tax.level = input$rank_selection,
        exact.tax.level = as.logical(input$exact_selection),
        min.size = input$min_selection
    )
    sigPool <- unique(unlist(sigs, use.names = FALSE))
    df <- simFun(inputSig, sigs) |> 
        dplyr::left_join(bsdbSub, by = c("bsdb_id" = "BSDB ID")) |>
        dplyr::mutate(Study = stringr::str_remove(.data$Study, "^Study "))
    
    dfDisplay <- df |> 
        dplyr::mutate(
            Study = stringr::str_c(
                '<a href="https://bugsigdb.org/Study_', .data$Study,
                '" target="_blank">', .data$Study, '</a>'
            )
        ) |>
        dplyr::select(-.data$bsdb_id)
    
    custom_colnames <- purrr::map(colnames(dfDisplay), appendHelp)
    
    input_exact_selection <- ifelse(input$exact_selection == TRUE, "Yes", "No")
    
    ## For the report
    paragraphs <- c(
        p1 = paste0("BugSigDB version: ", formals(bugsigdbr::importBugSigDB)$version),
        p2 = paste0("Unique taxa in the BugSigDB signature pool: ", format(length(sigPool), big.mark = ",", scientific = FALSE)),
        p3 = paste0("bugsigdbr version: ", packageVersion("bugsigdbr")),
        
        p4 = paste0("Number of input taxa: ", length(vct_lgl)),
        p5 = paste0("Number of inconsistent input identifiers: ", sum(!vct_lgl)),
        p6 = paste0("Number of indentifiers not found in BugSigDB: ", sum(!inputSig %in% sigPool)),
        
        p7 = paste0("Identifier type: ", input$type_selection),
        p8 = paste0("Rank(s): ", paste(input$rank_selection, collapse = ", ")),
        p9 = paste0("Exact: ", input_exact_selection),
        p10 = paste0("Minimum signature size: ", input$min_selection)
    )
    
    ## Handling outputs after analyzing #################################
    output$result_header <- shiny::renderUI({
        htmltools::tagList(
            htmltools::h3("Result"),
            htmltools::tags$br(),
            htmltools::p(paragraphs[["p1"]]),
            htmltools::p(paragraphs[["p2"]]),
            htmltools::p(paragraphs[["p3"]]),
            htmltools::tags$br(),
            htmltools::p(paragraphs[["p4"]]),
            htmltools::p(paragraphs[["p5"]]),
            htmltools::p(paragraphs[["p6"]]),
            htmltools::tags$br(),
            htmltools::p(paragraphs[["p7"]]),
            htmltools::p(paragraphs[["p8"]]),
            htmltools::p(paragraphs[["p9"]]),
            htmltools::p(paragraphs[["p10"]]),
            htmltools::tags$br()
        )
    })
    output$result_table <- DT::renderDataTable(
        DT::datatable(
            data = dfDisplay,
            escape = FALSE,
            rownames = FALSE,
            selection = "none",
            # container = htmltools::tags$table(
            #     class = 'display',
            #     htmltools::tags$thead(
            #         htmltools::tags$tr(
            #             lapply(custom_colnames, htmltools::tags$th)
            #         )
            #     )
            # ),
            # options = list(ordering = TRUE)
            container = htmltools::tags$table(
                class = 'display',
                htmltools::tags$thead(
                    htmltools::tags$tr(
                        lapply(custom_colnames, function(col) {
                            htmltools::tags$th(
                                class = "no-sort",
                                col
                            )
                        })
                    )
                )
            ),
            options = list(
                columnDefs = list(
                    list(orderable = FALSE, targets = "_all")
                ),
                ordering = FALSE
            )
        ) 
    )
    
    output$downloadData <- shiny::downloadHandler(
        filename = function() {
            paste("BugSigDBEnrich-", Sys.Date(), ".tsv", sep = "")
        },
        content = function(file) {
            utils::write.table(
                x = df, file, row.names = FALSE,
                sep = "\t"
            )
        }
    )
}
