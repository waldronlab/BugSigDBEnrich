
# Text --------------------------------------------------------------------
generateExampleText <- function(x) {
    paste(exampleSigs[[x]], collapse = "\n")
}

textBoxExamplesServer <- function(input, session) {
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
    shiny::observeEvent(input$badsig_box, {
        shiny::updateTextInput(
            session = session, 
            inputId = "text_input",
            value = generateExampleText("badsig")
        )
    })
}

# Files -------------------------------------------------------------------
getExamplePaths <- function() {
    ncbi <- system.file(
        "extdata", "ncbi.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    taxname <- system.file(
        "extdata", "taxname.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    metaphlan <- system.file(
        "extdata", "metaphlan.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    list(
        ncbi = ncbi,
        taxname = taxname,
        metaphlan = metaphlan
    )
}

fileInputExamplesServer <- function(output) {
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
}
