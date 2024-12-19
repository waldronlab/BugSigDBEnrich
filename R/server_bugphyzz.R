
# Results -----------------------------------------------------------------
bugphyzzResult <- function(input, output, inputSigFun, b, dat, sigs_rval, obo) {
    
    inputSig <- inputSigFun()
    
    bugphyzzInputOptionsChecks(input, inputSig)
    
    inputType <-  unique(whichType(inputSig))
    
    if (any(is.na(inputType)) || length(inputType) != 1) {
        shiny::showNotification(
            stringr::str_c(
                "❌I All taxa identifiers must be of the same type. ",
            ),
            duration = 8,
            type = "error"
        )
        shiny::req(FALSE)
    }
    
    # vct_lgl <- isType(inputSig, input$bugphyzz_type)
    # if (isFALSE(all(vct_lgl))) {
    #     shiny::showNotification(
    #         stringr::str_c(
    #             "❌Inconsistent identifiers. ",
    #             sum(vct_lgl == FALSE), " of ", length(vct_lgl),
    #             " identifiers are inconsistent. Input type and selected input type must match."
    #         ),
    #         duration = 8,
    #         type = "error"
    #     )
    #     shiny::req(FALSE)
    # }
    
    ranks <- checkRanks(input, inputSig, "bugphyzz", inputType)
    print(ranks)
    
    subB <- b()[input$bugphyzz_attributes]
    idType <- dplyr::case_when(
        inputType == "ncbi" ~ "NCBI_ID",
        inputType == "taxname" ~ "Taxon_name",
        inputType == "metaphlan" ~ "Taxon_name"
        # input$bugphyzz_type == "ncbi" ~ "NCBI_ID",
        # input$bugphyzz_type == "taxname" ~ "Taxon_name",
        # input$bugphyzz_type == "metaphlan" ~ "Taxon_name"
    )
    print(idType)
    sigs <- purrr::map(subB, ~ {
        bugphyzz::makeSignatures(
            dat = .x,
            taxIdType = idType,
            taxLevel = input$bugphyzz_rank,
            evidence = input$bugphyzz_evidence,
            frequency = input$bugphyzz_frequency,
            minSize = input$bugphyzz_min
        )
        }) |>
        purrr::list_flatten(name_spec = "{inner}") |> 
        purrr::discard( ~ !length(.x))
    names(sigs) <- sub("bugphyzz*:", "", names(sigs))
    
    sigPool <- unique(unlist(sigs, use.names = FALSE))
    
    # if (input$bugphyzz_type == "metaphlan") {
    if (inputType == "metaphlan") {
        inputSig <- inputSig |> 
            stringr::str_extract("[^|]+$") |> 
            stringr::str_remove("^[a-zA-Z]__")
    }
    
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
    df <- simFun(inputSig, sigs, input = input, obo = obo)
    waiter::waiter_hide()
    
    dat(df)
    sigs_rval(sigs)
    
    resultHeader <- stringr::str_c(
        "### Bugphyzz results\n\n",
        "bugphyzz version: ", formals(bugphyzz::importBugphyzz)$version, "  \n",
        "Unique taxa in the pool of signatures: ", format(length(sigPool), big.mark = ",", scientific = FALSE), "  \n",
        "bugphyzz version: ", as.character(utils::packageVersion("bugphyzz")), "  \n\n",
        # "Number of input taxa: ", length(vct_lgl), "  \n",
        # "Number of inconsistent identifiers: ", sum(!vct_lgl), "  \n",
        "Number of identifiers not found in bugphyzz: ", sum(!inputSig %in% sigPool), "\n\n",
        "Attributes: ", paste(input$bugphyzz_attributes, collapse = ", "), "  \n",
        "Identifier type: ", inputType, "  \n",
        # "Identifier type: ", input$bugphyzz_type, "  \n",
        "Rank(s): ", paste(input$bugphyzz_rank, collapse = ", "), "  \n",
        "Evidence: ", paste(input$bugphyzz_evidence, collapse = ", "), "  \n",
        "Frequency: ", paste(input$bugphyzz_frequency, collapse = ", "), "  \n",
        "Minimum signature size: ", input$bugphyzz_min, "  \n"
    )
    
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
    
    output$result_header <- shiny::renderUI({shiny::markdown(resultHeader)})
    
    if (!is.null(ranks)) {
        wrongRanks <- purrr::imap(ranks, ~ paste0(.y, " (", .x, ")")) |> 
            purrr::flatten_chr() |> 
            paste(collapse = ", ")
        output$rank_warning <- shiny::renderUI({
            htmltools::p(
                shiny::icon(
                    "exclamation-triangle", class = "text-warning"
                ),
                stringr::str_c("Taxa with mismatching ranks: ", wrongRanks)
            ) 
        })
    } 
    
    output$result_table <- DT::renderDT({
        dfDisplay <- df |> 
            dplyr::mutate(
                Signature = stringr::str_c(
                    '<a href="javascript:void(0);" class="signature-link" id="signature_',
                    dplyr::row_number(), '">', .data$Signature, '</a>'
                )
            )
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
                headerCallback = DT::JS("
            function(thead, data, start, end, display) {
                $(thead).find('th').css('text-align', 'center');
            }
        "),
                initComplete = DT::JS("
            function(settings, json) {
                setTimeout(() => {
                    const tooltipTriggerList = document.querySelectorAll('#table-container th[title]');
                    tooltipTriggerList.forEach(element => {
                        new bootstrap.Tooltip(element, { html: true });
                    });
                }, 100);
            }
        ")
            )
        )
        # dt <- DT::datatable(
        #     dfDisplay,
        #     rownames = FALSE,
        #     escape = FALSE,
        #     selection = "none",
        #     container = htmltools::withTags(
        #         htmltools::tags$table(
        #             class = 'display',
        #             htmltools::tags$thead(htmltools::tags$tr(tag_list))
        #         )
        #     ),
        #     options = list(
        #         headerCallback = DT::JS("function(thead, data, start, end, display) {
        #         $(thead).find('th').css('text-align', 'center');
        #     }")
        #     )
        # )
        # dt$dependencies <- appendDTDeps(dt)
        dt$dependencies <- c(dt$dependencies, appendDTDeps())
        dt
    })
    
    output$downloadData <- shiny::downloadHandler(
        filename = function() {
            paste("BugSigDBEnrich-bugphyzz-", Sys.Date(), ".tsv", sep = "")
        },
        content = function(file) {
            utils::write.table(
                x = df, file, row.names = FALSE,
                sep = "\t"
            )
        }
    )
}

# Input checks ------------------------------------------------------------

bugphyzzInputOptionsChecks <- function(input, inputSig) {
    if (!length(input$bugphyzz_attributes)) {
        shiny::showNotification(
            "❌ No attribute selected. Select at least one attribute option.", 
            type = "error"
        )
        shiny::req(FALSE, cancelOutput = "progress")
    }
    if (!length(input$bugphyzz_rank)) {
        shiny::showNotification(
            "❌  No rank selected. Select at least one rank option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
    if (!length(input$bugphyzz_evidence)) {
        shiny::showNotification(
            "❌  No evidence selected. Select at least one evidence option.",
            type = "error"
        )
        shiny::req(FALSE)
    }
    if (!length(input$bugphyzz_frequency)) {
        shiny::showNotification(
            "❌  No frequency selected. select at least one frequency option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
}

# Options -----------------------------------------------------------------
bugphyzzOptionsServer <- function(input, session, b) {
    list(
        shiny::observe({
            shinyWidgets::updatePickerInput(
                session = session,
                inputId = "bugphyzz_attributes",
                choices = sort(names(b)),
                selected = sort(names(b)),
                options = list(
                    `actions-box` = TRUE,
                    `live-search` = TRUE,
                    `selected-text-format` = "count > 1",
                    countSelectedText = "{0} attributes selected",
                    title = "Select attributes"
                )
            )
        }),
        shiny::observeEvent(input$bugphyzz_rank_mixed, {
            if (input$bugphyzz_rank_mixed) {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_rank",
                    selected = rankOptions("bugphyzz")
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_rank",
                    selected = character(0)
                )
            }
        }),
        shiny::observeEvent(input$bugphyzz_evidence_mixed, {
            if (input$bugphyzz_evidence_mixed) {
                shiny::updateCheckboxGroupInput(
                    session = session, 
                    inputId = "bugphyzz_evidence",
                    selected = bugphyzzEvidenceOptions()
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_evidence",
                    selected = character(0)
                )
            }
        }),
        shiny::observeEvent(input$bugphyzz_frequency_mixed, {
            if (input$bugphyzz_frequency_mixed) {
                shiny::updateCheckboxGroupInput(
                    session = session, 
                    inputId = "bugphyzz_frequency",
                    selected = bugphyzzFrequencyOptions()
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_frequency",
                    selected = character(0)
                )
            }
        })
    )
}

# Help --------------------------------------------------------------------
bugphyzzOptionsHelp <- function(input) {
    list(
        shiny::observeEvent(input$bugphyzz_attributes_help, {
            helpModal(
                "Attributes",
                stringr::str_c(
                    "Select one or more bugphyzz attributes containing phenotypic traits. ",
                    helpPageDiv("More...", "bugphyzzoptions")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bugphyzz_type_help, {
            helpModal(
                "Identifier type",
                stringr::str_c(
                    "Select the identifier that matches your input. ",
                    "Metaphlan identifiers will be converted to taxname identifiers. ",
                    helpPageDiv("More...", "bugphyzzoptions")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bugphyzz_rank_help, {
            helpModal(
                "Taxonomic rank",
                stringr::str_c(
                    "Check the rank(s) of the taxa that should be included in the Bugphyzz signatrues. ",
                    "Check '(de)select all' to select all or none. ",
                    helpPageDiv("More...", "bugphyzzoptions")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bugphyzz_evidence_help, {
            helpModal(
                "Evidence",
                stringr::str_c(
                    "exp = wet lab experiments, ",
                    "igc = inferred from genomic context, ",
                    "tas = traceable author statement, ",
                    "nas = non-traceable author statement, ",
                    "tax = taxonomic progagation from strain to species, ",
                    "asr = ancestral state reconstruction. ",
                    "Check '(de)select all' to select all or none. ",
                    helpPageDiv("More...", "bugphyzzoptions")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bugphyzz_frequency_help, {
            helpModal(
                "Frequency",
                stringr::str_c(
                    "Confidence of the annotations in Bugzphyzz. ",
                    "always: 1, ",
                    "usually: >= 0.8 & < 1, ",
                    "sometimes: >= 0.5 < 0.8, ",
                    "unknown: Not enough information to determine ",
                    "Check '(de)select all' to select all or none. ",
                    helpPageDiv("More...", "bugphyzzoptions")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bugphyzz_min_help, {
            helpModal(
                "Minimum signature size",
                stringr::str_c(
                    "Minimum number of IDs in the target Bugphyzz signature. ",
                    helpPageDiv("More...", "bugphyzzoptions")
                    # "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        })
    )
}
