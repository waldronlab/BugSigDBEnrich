
#' Launch my app
#'
#' @return A shinyApp
#' @export
#'
myApp <- function() shiny::shinyApp(ui = createUI(), server = server)

## Create user interface
createUI <- function() {
    ui <- shiny::fluidPage(
        shiny::tags$head(
          ## This chunk is for the "top button" (maybe remove it)
            shiny::tags$style(htmltools::HTML(topButtonShape())),
            shiny::tags$script(htmltools::HTML(topButtonAction()))
        ),
        
        ## Header
        theme = shinythemes::shinytheme("united"),
        shiny::titlePanel("BugSigDBEnrich"),
        htmltools::h4(htmltools::HTML(stringr::str_c(
            "Run enrichment and similarity analyses against ",
            '<a href="https://bugsigdb.org" target="_blank">BugSigDB</a>',
            " signatures"
        ))),
        htmltools::h3("Input"),
        
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
            accept = c(".gmt"),
            buttonLabel = "Choose file..."
        ),
        
        shiny::tags$hr(),
        
        ## Buttons
        shiny::actionButton(
            inputId = "analyzeButton", 
            label = "Analyze",
            icon = shiny::icon("table")
        ),
        shiny::downloadButton(
            outputId = "downloadData",
            label = "Download result"
        ),
        shiny::actionButton(
            inputId = "resetButton", 
            label = "Reset app",
            icon = shiny::icon("refresh")
        ),
        
        ## This chunk is for the "top button" (maybe remove it)
        shiny::actionButton(
            inputId = "top_button",
            label = "\u2191",
            onclick = "scrollToTop()"),
        
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
    
    signature <- shiny::reactive({
        shiny::req(input$file_input)
        ext <- tools::file_ext(input$file_input$name)
        switch(ext,
               gmt = readGMT(input$file_input$datapath),
               shiny::validate("Invalid file; Please upload a GMT file")
        )
    })
    
    shiny::observeEvent(input$resetButton, {
        session$reload()
    })
    
    ## What happens when analyze is used
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
                Study = stringr::str_remove(.data$Study, "^Study "),
                Study = stringr::str_c(
                    '<a href="https://bugsigdb.org/Study_', .data$Study,
                    '" target="_blank">', .data$Study, '</a>'
                )
            ) |>
            dplyr::select(-.data$bsdb_id)
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
