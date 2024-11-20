bugphyzzResult <- function(input, output, inputSigFun, b, dat, sigs_rval) {
    
    inputSig <- inputSigFun()
    
    bugphyzzInputOptionsChecks(input, inputSig)
    
    vct_lgl <- isType(inputSig, input$bugphyzz_type)
    if (isFALSE(all(vct_lgl))) {
        shiny::showNotification(
            stringr::str_c(
                sum(vct_lgl == FALSE), " of ", length(vct_lgl),
                " identifiers are inconsistent. Please review their format."
            ),
            type = "warning"
        )
    }
    
    subB <- b[input$bugphyzz_attributes]
    idType <- dplyr::case_when(
        input$bugphyzz_type == "ncbi" ~ "NCBI_ID",
        input$bugphyzz_type == "taxname" ~ "Taxon_name",
        input$bugphyzz_type == "metaphlan" ~ "Taxon_name"
    )
    
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
    
    if (input$bugphyzz_type == "metaphlan") {
        inputSig <- inputSig |> 
            stringr::str_extract("[^|]+$") |> 
            stringr::str_remove("^[a-zA-Z]__")
    }
    
    df <- simFun(inputSig, sigs)
    
    dat(df)
    sigs_rval(sigs)
    
    resultHeader <- stringr::str_c(
        "### Bugphyzz results\n\n",
        "bugphyzz version: ", formals(bugphyzz::importBugphyzz)$version, "  \n",
        "Unique taxa in the pool of signatures: ", format(length(sigPool), big.mark = ",", scientific = FALSE), "  \n",
        "bugphyzz version: ", as.character(utils::packageVersion("bugphyzz")), "  \n\n",
        "Number of input taxa: ", length(vct_lgl), "  \n",
        "Number of inconsistent identifiers: ", sum(!vct_lgl), "  \n",
        "Number of identifiers not found in bugphyzz: ", sum(!inputSig %in% sigPool), "\n\n",
        "Attributes: ", paste(input$bugphyzz_attributes, collapse = ", "), "  \n",
        "Identifier type: ", input$bugphyzz_type, "  \n",
        "Rank(s): ", paste(input$bugphyzz_rank, collapse = ", "), "  \n",
        "Evidence: ", paste(input$bugphyzz_evidence, collapse = ", "), "  \n",
        "Frequency: ", paste(input$bugphyzz_frequency, collapse = ", "), "  \n",
        "Minimum signature size: ", input$bugphyzz_min, "  \n"
    )
    
    output$result_header <- shiny::renderUI({shiny::markdown(resultHeader)})
    
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