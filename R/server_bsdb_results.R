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
    
    shiny::observeEvent(input$clicked_name, {
        clicked_id <- input$clicked_name
        row_id <- as.numeric(sub("name_", "", clicked_id))
        tab_title <- stringr::str_extract(
            df$Signature[row_id], "bsdb:\\d+/\\d+/\\d+"
        )
        
        if (is.null(open_tabs[[tab_title]])) {
            open_tabs[[tab_title]] <- TRUE
            new_tab <- shiny::tabPanel(
                # title = tab_title,
                title = div(tab_title, 
                            span("x", class = "close-tab", style = "margin-left: 8px;")),
                
                p(paste0("Just in input: ", paste(setdiff(inputSig, sigs[[df$Signature[row_id]]]), collapse = ", "))),
                p(paste0("In both: ", paste(intersect(inputSig, sigs[[df$Signature[row_id]]]), collapse = ", "))),
                p(paste0("Just in target: ", paste(setdiff(sigs[[df$Signature[row_id]]], inputSig), collapse = ", "))),
                
            )
            
            appendTab("main_tabs", new_tab, select = TRUE)
        }
    })
    
    observeEvent(input$close_tab, {
        tab_title <- input$close_tab
        removeTab("main_tabs", target = tab_title)
        open_tabs[[tab_title]] <- NULL
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

.addTabCloseFeature <- function() {
    tags$head(
        tags$script(HTML("
      $(document).on('click', '.close-tab', function(e) {
        e.stopPropagation(); // Prevent tab switch on close
        var tabId = $(this).parent().attr('data-value');
        Shiny.setInputValue('close_tab', tabId, {priority: 'event'});
      });
    ")),
        tags$style(HTML("
      .nav-tabs .close-tab {
        font-size: 12px;
        color: #aaa;
        margin-left: 5px;
        cursor: pointer;
      }
      .nav-tabs .close-tab:hover {
        color: #333;
      }
    "))
    )
}




