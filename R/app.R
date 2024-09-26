myApp <- function() {
    ui <- .createUI()
    shiny::shinyApp(ui = ui, server = .server)
}

.createUI <- function() {
    ui <- shiny::fluidPage(
        shiny::fileInput(
            inputId = "upload",
            label = "Upload list of taxa.",
            accept = c(".gmt")
        ),
        shiny::textOutput("sig"),
        shiny::actionButton("button", "Run Jaccard similarity"),
        shiny::tableOutput("jaccard")
    )
    return(ui)
}

.server <- function(input, output) {
    signature <- reactive({
        shiny::req(input$upload)
        ext <- tools::file_ext(input$upload$name)
        switch(ext,
               gmt = readGMT(input$upload$datapath),
               shiny::validate("Invalid file; Please upload a GMT file")
        )
    })
    output$sig <- shiny::renderText({
        paste0(
            "Your first six taxa out of ", length(signature()), " are: ",
            paste(head(signature()), collapse = ", " ),
            "..."
        )
    })
    observeEvent(input$button, {
        bsdb <- bugsigdbr::importBugSigDB()
        sigs <- bugsigdbr::getSignatures(
            bsdb,
            tax.id.type = "ncbi", tax.level = "genus", exact.tax.level = TRUE,
            min.size = 5
        )
        inputSig <- signature()
        df <- jacSim(inputSig, sigs)
        output$jaccard <- shiny::renderTable({
            df
        })
    })
}
