
#' Create server
#'
#' @param input Input shiny.
#' @param output Output shiny.
#' @param session Session shiny.
#' 
#' @importFrom rlang .data 
#'
#' @return A shinyApp
#'
server <- function(input, output, session) {
    
    bsdb <- bugsigdbr::importBugSigDB()
    bsdbSub <- bsdb[,c("BSDB ID", "Study"), drop = FALSE]
   
    ## Examples section 
    shiny::observeEvent(input$ncbi_box, {
        shiny::updateTextInput(
            session = session,
            inputId = "text_input",
            value = generateExampleText("ncbi")
        )
    })
    shiny::observeEvent(input$taxname_box, {
        shiny::updateTextInput(
            session = session, 
            inputId = "text_input",
            value = generateExampleText("taxname")
        )
    })
    shiny::observeEvent(input$metaphlan_box, {
        shiny::updateTextInput(
            session = session,
            inputId =  "text_input",
            value = generateExampleText("metaphlan")
        )
    }) 
    output$downloadExampleNCBI <- shiny::renderUI({
        shiny::downloadLink("ncbiDownload", "ncbi")
    })
    output$downloadExampleTaxname <- shiny::renderUI({
        shiny::downloadLink("taxnameDownload", "taxname")
    })
    output$downloadExampleMetaphlan <- shiny::renderUI({
        shiny::downloadLink("metaphlanDownload", "metaphlan")
    })
    output$ncbiDownload <- shiny::downloadHandler(
        filename = function() "ncbi.txt",
        content = function(file) file.copy(getExamplePaths()$ncbi, file)
    )
    output$taxnameDownload <- shiny::downloadHandler(
        filename = function() "taxname.txt",
        content = function(file) file.copy(getExamplePaths()$taxname, file)
    )
    output$metaphlanDownload <- shiny::downloadHandler(
        filename = function() "metaphlan.txt",
        content = function(file) file.copy(getExamplePaths()$metaphlan, file)
    )
    
    resetApp(input, session)
    inputSigFun <- inputSignature(input) # inputSigFun is a function
    selectAllRanks(input, session)
    
    ## Analysis
    shiny::observeEvent(input$analyzeButton, {
        if (!length(input$rank_selection)) {
            shiny::showNotification(
                "Please select at least one rank option.", 
                type = "error"
            )
        } else {
            inputSig <- inputSigFun()
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
            
            ## Create a result table to download 
            dfDownload <- df |> 
                dplyr::mutate(
                    Study = sub(
                        "^.*https://bugsigdb.org/Study_(\\d+).*$", "\\1",
                        .data$Study
                    )  
                )
            
            ## Handling outputs after analyzing
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
    })
}
