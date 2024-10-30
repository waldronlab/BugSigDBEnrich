bugphyzzResult <- function(input, output, inputSigFun, b) {
    
    if (!length(input$bugphyzz_attributes)) {
        shiny::showNotification(
            "Please select at least one attribute option.", 
            type = "error"
        )
        return(NULL)
    }
    if (!length(input$bugphyzz_rank)) {
        shiny::showNotification(
            "Please select at least one rank option.", 
            type = "error"
        )
        return(NULL)
    }
    if (!length(input$bugphyzz_evidence)) {
        shiny::showNotification(
            "Please select at least one evidence option.", 
            type = "error"
        )
        return(NULL)
    }
    if (!length(input$bugphyzz_frequency)) {
        shiny::showNotification(
            "Please select at least one frequency option.", 
            type = "error"
        )
        return(NULL)
    }
    
    inputSig <- inputSigFun()
    
    isMeta <- which("metaphlan" %in% whichType(inputSig))
    if (length(isMeta) >= 1) {
        shiny::showNotification(
            stringr::str_c(
                "Metaphlan not supported for bugphyzz. ",
                length(isMeta), " of ", length(inputSig),
                " identifiers are metaphlan. Please review their id type."
            ),
            type = "error"
        )
        return(NULL)
    }
    
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