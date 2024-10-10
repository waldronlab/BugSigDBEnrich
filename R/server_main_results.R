
mainResult <- function(input, output, inputSigFun, bsdb) {
    ## Analysis #######################################################
    inputSig <- inputSigFun()
    bsdbSub <- bsdb[,c("BSDB ID", "Study"), drop = FALSE]
    sigs <- bugsigdbr::getSignatures(
        df = bsdb,
        tax.id.type = input$type_selection,
        tax.level = input$rank_selection,
        exact.tax.level = as.logical(input$exact_selection),
        min.size = input$min_selection
    )
    sigPool <- unlist(sigs, use.names = FALSE)
    df <- simFun(inputSig, sigs)
    df <- dplyr::left_join(df, bsdbSub, by = c("bsdb_id" = "BSDB ID")) |>
        dplyr::mutate(
            Study = stringr::str_remove(.data$Study, "^Study "),
            Study = stringr::str_c(
                '<a href="https://bugsigdb.org/Study_', .data$Study,
                '" target="_blank">', .data$Study, '</a>'
            )
        ) |>
        dplyr::select(-.data$bsdb_id)
    
    ## Create downloable table (remove hyperlinks)
    dfDownload <- df |> 
        dplyr::mutate(
            Study = sub(
                "^.*https://bugsigdb.org/Study_(\\d+).*$", "\\1",
                .data$Study
            )  
        )
    
    ## Handling outputs after analyzing #################################
    output$result_header <- shiny::renderUI({
        htmltools::h3("Result")
    })
    output$result_table <- DT::renderDT(
        DT::datatable(
            data = df, escape = FALSE, rownames = FALSE,
            selection = "none"
        )
    )
    output$downloadData <- shiny::downloadHandler(
        filename = function() {
            paste("BugSigDBEnrich-", Sys.Date(), ".tsv", sep = "")
        },
        content = function(file) {
            utils::write.table(
                x = dfDownload, file, row.names = FALSE,
                sep = "\t"
            )
        }
    )
}
