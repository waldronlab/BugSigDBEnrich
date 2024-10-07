
#' Launch my app
#'
#' @return A shinyApp
#' @export
#'
myApp <- function() shiny::shinyApp(ui = createUI(), server = server)

createUI <- function() {
    ui <- shiny::fluidPage(
        
        topButton(),
        topButtonAction(),
        
        theme = shinythemes::shinytheme("united"),
        
        shiny::titlePanel("BugSigDBEnrich"),
        htmltools::h4(appSubtitle()),
        
        htmltools::h3("Input"), #####################################
        textInputBox(),
        fileInputBox(),
        shiny::tags$hr(),
        
        htmltools::h3("Target options"), ############################
        idTypeRadioButtons(),
        selectRankCheckBox(),
        selectAllRanksCheckBox(),
        exactRankButton(),
        minSigSize(),
        shiny::tags$hr(),
        
        htmltools::h3("Actions"), #############################################
        analyzeButton(),
        downloadResultButton(),
        resetButton(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("jaccard")
    )
}

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
    
    ## Load bugsigdbr when the app starts.
    bsdb <- bugsigdbr::importBugSigDB()
    bsdbSub <- bsdb[,c("BSDB ID", "Study"), drop = FALSE]
    
    signature <- shiny::reactive({
        # shiny::req(input$text_input)
        # readBox(input$text_input)
        # 
        
        shiny::req(input$file_input)
        ext <- tools::file_ext(input$file_input$name)
        switch(ext,
               gmt = readGMT(input$file_input$datapath),
               shiny::validate("Invalid file; Please upload a GMT file")
        )
    })

    ## Observations 1 - Reset app
    shiny::observeEvent(input$resetButton, {
        session$reload()
    })
    
    ## Observation 2 - Analysis
    shiny::observeEvent(input$analyzeButton, {
        ## Create a result table to display
        sigs <- bugsigdbr::getSignatures(
            bsdb,
            tax.id.type = "ncbi", tax.level = "genus", exact.tax.level = TRUE,
            min.size = 5
        )
        inputSig <- signature()
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
        
    })
}

# TODO list ---------------------------------------------------------------

## In the output add signature size
## Maybe include a commented header with the results
## Just download a zip file
