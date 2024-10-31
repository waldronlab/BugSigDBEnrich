bsdbResult <- function(input, output, inputSigFun, bsdb, session) {
    inputSig <- inputSigFun()
    bsdbInputOptionsChecks(input, inputSig)
    
    vct_lgl <- isType(inputSig, input$bsdb_type)
    if (isFALSE(all(vct_lgl))) {
        shiny::showNotification(
            stringr::str_c(
                sum(vct_lgl == FALSE), " of ", length(vct_lgl),
                " identifiers are inconsistent. Please review their format."
            ),
            type = "warning"
        )
    }
    
    bsdbSub <- bsdb[, c("BSDB ID", "Study"), drop = FALSE]
    sigs <- bugsigdbr::getSignatures(
        df = bsdb,
        tax.id.type = input$bsdb_type,
        tax.level = input$bsdb_rank,
        exact.tax.level = as.logical(input$bsdb_exact),
        min.size = input$bsdb_min
    )
    sigPool <- unique(unlist(sigs, use.names = FALSE))
    df <- simFun(inputSig, sigs, opt = "bsdb") |> 
        dplyr::left_join(bsdbSub, by = c("bsdb_id" = "BSDB ID")) |>
        dplyr::mutate(Study = stringr::str_remove(.data$Study, "^Study "))
    
    resultHeader <- stringr::str_c(
        "### BugSigDB results\n\n",
        "BugSigDB version: ", formals(bugsigdbr::importBugSigDB)$version, "  \n",
        "Unique taxa in the pool of signatures: ", format(length(sigPool), big.mark = ",", scientific = FALSE), "  \n",
        "bugsigdbr version: ", as.character(utils::packageVersion("bugsigdbr")), "  \n\n",
        "Number of input taxa: ", length(vct_lgl), "  \n",
        "Number of inconsistent identifiers: ", sum(!vct_lgl), "  \n",
        "Number of identifiers not found in BugSigDB: ", sum(!inputSig %in% sigPool), "\n\n",
        "Identifier type: ", input$bsdb_type, "  \n",
        "Rank(s): ", paste(input$bsdb_rank, collapse = ", "), "  \n",
        "Exact: ", ifelse(input$bsdb_exact == TRUE, "Yes", "No"), "  \n",
        "Minimum signature size: ", input$bsdb_min, "  \n"
    )
    
    output$result_header <- shiny::renderUI({ shiny::markdown(resultHeader)})
    
    output$result_table <- DT::renderDT({
        dfDisplay <- df |> 
            dplyr::mutate(
                Study = stringr::str_c(
                    '<a href="https://bugsigdb.org/Study_', .data$Study,
                    '" target="_blank">', .data$Study, '</a>'
                ),
                Signature = stringr::str_c(
                    "<a href=\"javascript:void(0);\" class=\"name-link\" id=\"name_", dplyr::row_number(), "\">", .data$Signature, "</a>" 
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
                $(thead).find('th').css('text-align', 'center'); // Center header text
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
    
    open_tabs <- shiny::reactiveValues()
    
    observeEvent(input$clicked_name, {
        clicked_id <- input$clicked_name
        row_id <- as.numeric(sub("name_", "", clicked_id))
        tab_title <- paste0("tab", row_id)
        
        if (is.null(open_tabs[[tab_title]])) {
            open_tabs[[tab_title]] <- TRUE
            new_tab <- tabPanel(
                title = tab_title,
                h3(paste("Details for", tab_title)),
                p(paste(head(sigs[[ df$Signature[row_id] ]]), collapse = ", ")),
                actionButton(inputId = paste0("close_", row_id), label = "Close Tab"),
                downloadButton(outputId = paste0("download_", row_id), label = "Download Text")
            )
            
            appendTab("main_tabs", new_tab, select = TRUE)
            
            output[[paste0("download_", row_id)]] <- downloadHandler(
                filename = function() {
                    paste("details_", row_id, ".txt", sep = "")
                },
                content = function(file) {
                    writeLines(
                        c(
                            paste("Details for:", tab_title),
                            paste("Row ID:", row_id),
                            "Additional content specific to this row can be added here."
                        ),
                        con = file
                    )
                }
            )
        }
    })
}

.tabOpener <- function() {
    tags$head(tags$script(HTML("
        $(document).on('click', '.name-link', function(e) {
            e.preventDefault();
            var id = $(this).attr('id');
            Shiny.setInputValue('clicked_name', id, {priority: 'event'});
        });
    ")))
}
