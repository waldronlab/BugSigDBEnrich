
#' Launch my app
#'
#' @return A shinyApp
#' @export
#'
myApp <- function() shiny::shinyApp(ui = createUI(), server = server)

## Create user interface
createUI <- function() {
    ui <- shiny::fluidPage(
        theme = shinythemes::shinytheme("cerulean"),
        shiny::titlePanel("BugSigDBEnrich"),
        shiny::h4(stringr::str_c(
            "Run enrichment and similarity analyses against BugSigDB signatures"
        )),
        
        shiny::h3("Input"),
        
        ## Input options
        shiny::textAreaInput(
            inputId = "text_input",
            label = stringr::str_c(
                "Paste valid taxon identifiers ",
                "(one element per line):"
            ),
            height = '200px',
            width = "500px"
        ),
        shiny::fileInput(
            inputId = "file_input",
            label = "OR upload a file:",
            accept = c(".gmt")
        ),
        
        tags$hr(),
        
        ## Buttons
        shiny::actionButton(
            inputId = "resetInputButton", 
            label = "Reset",
            icon = shiny::icon("refresh")
        ),
        shiny::actionButton(
            inputId = "analyzeButton", 
            label = "Analyze",
            icon = shiny::icon("table")
        ),
        shiny::actionButton(
            inputId = "downloadButton", 
            label = "Download",
            icon = shiny::icon("download")
        ),
        
        tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("jaccard")
    )
}

#' Create server
#'
#' @param input Input shiny.
#' @param output Output shiny.
#' 
#' @importFrom rlang .data 
#'
#' @return A shinyApp
#'
server <- function(input, output) {
    
    ## Load bugsigdbr when the app starts.
    bsdb <- bugsigdbr::importBugSigDB()
    
    signature <- shiny::reactive({
        shiny::req(input$file_input)
        ext <- tools::file_ext(input$file_input$name)
        switch(ext,
               gmt = readGMT(input$file_input$datapath),
               shiny::validate("Invalid file; Please upload a GMT file")
        )
    })
    
    ## Generating the output
    shiny::observeEvent(input$analyzeButton, {
        sigs <- bugsigdbr::getSignatures(
            bsdb,
            tax.id.type = "ncbi", tax.level = "genus", exact.tax.level = TRUE,
            min.size = 5
        )
        inputSig <- signature()
        df <- jacSim(inputSig, sigs)
        bsdbSub <- bsdb[,c("BSDB ID", "Study"), drop = FALSE]
        df <- dplyr::left_join(df, bsdbSub, by = c("bsdb_id" = "BSDB ID")) |>
            dplyr::mutate(
                Study = stringr::str_replace(.data$Study, " ", "_"),
                study_link = stringr::str_c(
                    '<a href="https://bugsigdb.org/', .data$Study,
                    '" target="_blank">', .data$Study, '</a>'
                )
            ) |>
            dplyr::select(-.data$bsdb_id, -.data$Study)
        
        output$result_header <- shiny::renderUI({
            h3("Result")
        })
        output$jaccard <- DT::renderDT(
            DT::datatable(df, escape = FALSE, rownames = FALSE)
        )
    })
}
