
# Results -----------------------------------------------------------------
bsdbResult <- function(input, output, inputSigFun, bsdb, dat, sigs_rval) {
    
    inputSig <- inputSigFun()
    
    if (!length(input$bsdb_rank)) {
        shiny::showNotification(
            "Please select at least one rank option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
    
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
    
    df <- simFun(inputSig, sigs, opt = "bsdb", input) |> 
        dplyr::left_join(bsdbSub, by = c("bsdb_id" = "BSDB ID")) |>
        dplyr::mutate(Study = stringr::str_remove(.data$Study, "^Study "))
    
    dat(df)
    sigs_rval(sigs)
    
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
}

# Options -----------------------------------------------------------------
bsdbSigOptionsServer <- function(input, session) {
    list(
        shiny::observeEvent(input$bsdb_rank_mixed, {
            if (input$bsdb_rank_mixed) {
                shiny::updateCheckboxGroupInput(
                    session, "bsdb_rank", selected = rankOptions()
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session, "bsdb_rank", selected = character(0)
                )
            }
        }),
        shiny::observe({
            if (length(input$bsdb_rank) > 1)
                shiny::updateRadioButtons(
                    session, "bsdb_exact", selected = TRUE
                )
        })
    )
}

# Help --------------------------------------------------------------------
bsdbSigOptionsHelp <- function(input) {
    list(
        shiny::observeEvent(input$bsdb_type_help, {
            helpModal(
                "Identifier type",
                stringr::str_c(
                    "Type of the target signatures in BugSigDB.",
                    " The type must match the input IDs. ",
                    helpPageDiv("More...", "options")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bsdb_rank_help, {
            helpModal(
                "Select taxonomic rank(s)",
                stringr::str_c(
                    "Select the rank(s) of the taxa included in the target BugSigDB signature.",
                    " Use the '(De)select all' check box to select or deselect all ranks at once. ",
                    helpPageDiv("More...", "options")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bsdb_exact_help, {
            helpModal(
                "Use exact taxonomiic level",
                stringr::str_c(
                    "If 'Yes', only ranks manually curated will be included.",
                    " If 'No', the taxonomic tree will be cut at the specified rank (above).",
                    " Only one rank (above) can be selected when the 'No' options is used. ",
                    helpPageDiv("More...", "options")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bsdb_min_help, {
            helpModal(
                "Minimum signature size",
                stringr::str_c(
                    "Minimum number of IDs to filter the target BugSigDB signatures. ",
                    helpPageDiv("More...", "options")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        })
    )
}
