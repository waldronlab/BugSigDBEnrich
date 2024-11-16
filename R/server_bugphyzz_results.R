bugphyzzResult <- function(input, output, inputSig, b) {
    
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
        input$bugphyzz_type == "taxname" ~ "Taxon_name"
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
    names(sigs) <- sub("^.*bugphyzz:", "", names(sigs))
    df <- simFun(inputSig, sigs)
    
    output$result_header <- shiny::renderUI({
        htmltools::tagList(
            htmltools::h3("Bugphyzz results")
        )
    })
    
    output$result_table <- DT::renderDT({
        dt <- DT::datatable(
            df,
            rownames = FALSE,
            escape = FALSE,
            selection = "none"
        )
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