
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
    
    resetApp(input, session)
    signature <- inputSignature(input)
    selectAllRanks(input, session)
    
    ## Observation 3 - Analysis
    shiny::observeEvent(input$analyzeButton, {
        
        if (!length(input$rank_selection)) {
            shiny::showNotification(
                "Please select at least one rank option.", 
                type = "error"
            )
        } else {
            
            if (input$exact_selection == "Yes") {
                exactVar <- TRUE
            } else if (input$exact_selection == "No") {
                exactVar <- FALSE
            }
            
            inputSig <- signature()
            
            sigs <- bugsigdbr::getSignatures(
                df = bsdb,
                tax.id.type = input$type_selection,
                tax.level = input$rank_selection,
                exact.tax.level = exactVar ,
                min.size = input$min_selection
            )
            
            df <- jacSim(inputSig, sigs)
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
            
            output$jaccard <- DT::renderDT(
                DT::datatable(df, escape = FALSE, rownames = FALSE)
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
