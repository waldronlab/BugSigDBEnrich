
bsdbResult <- function(input, output, inputSigFun, bsdb, session, open_tabs) {
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
    
    sigs2_type <- dplyr::case_when(
        input$bsdb_type == "ncbi" ~ "taxname",
        input$bsdb_type == "taxname" ~ "ncbi",
        input$bsdb_type == "metaphlan" ~ "ncbi"
    )
    sigs2 <- bugsigdbr::getSignatures(
        df = bsdb,
        tax.id.type = sigs2_type,
        tax.level = input$bsdb_rank,
        exact.tax.level = as.logical(input$bsdb_exact),
        min.size = input$bsdb_min
    )
    
    sigs2 <- sigs2[names(sigs)]
    sigs <- purrr::map2(sigs, sigs2, ~ {
        names(.x) <- .y
        .x
    })
    
    print(sigs[[1]])
    
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
    
    shiny::observeEvent(input$clicked_signature, {
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
        removeTab(inputId = "main_tabs", target = tab_id)
    })
}
