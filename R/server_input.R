
# Input -------------------------------------------------------------------
inputSignature <- function(input) {
    shiny::reactive({
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        
        if (cond1) {
            inputSig <- unlist(strsplit(input$text_input, "\n"))
            inputSig <- inputSig[inputSig != ""]
        } else if (cond2) {
            inputSig <- switch(
                tools::file_ext(input$file_input$name),
                txt = readLines(con = input$file_input$datapath),
                shiny::validate("Invalid file; Please upload a .txt file")
            )
        } else {
            shiny::showNotification("No input", type = "error")
            shiny::req(FALSE)
        }
        return(inputSig)
    })
}

whichType <- function(x) {
    dplyr::case_when(
        stringr::str_detect(x, "^\\d+$") ~ "ncbi",
        stringr::str_detect(x, "^[a-zA-Z]{1}__.*?(\\|[a-zA-Z]{1}__.*?)*$") ~ "metaphlan",
        stringr::str_detect(x, "^.+$") ~ "taxname",
        is.na(x) ~ NA
    )
}

isType <- function(input_sig, input_type) {
    whichType(input_sig) == input_type
}

# Example text ------------------------------------------------------------
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

# Example files -----------------------------------------------------------

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


# Help --------------------------------------------------------------------
inputHelp <- function(input) {
    list(
        shiny::observeEvent(input$inputtext_help_link, {
            helpModal(
                "Enter list of NCBI taxids, taxon names, or metaphlan names",
                htmltools::HTML(
                    stringr::str_c(
                        "Enter a list of IDs; one per line.",
                        " The IDs can be in 'ncbi', 'taxname', or 'metaphlan' format.",
                        " Cick on the examples below to fill the text box with sample IDs. ",
                        "<a href='?tab=help&anchor=#input' target='_blank'>More...</a>"
                    )
                )
            )
        }),
        shiny::observeEvent(input$inputfile_help_link, {
            helpModal(
                "Upload a file:",
                htmltools::HTML(
                    stringr::str_c(
                        "A text file with '.txt' extension containing one ID per line.",
                        " Click on the examples below to download a sample file. ",
                        "<a href='?tab=help&anchor=#input' target='_blank'>More...</a>"
                    )
                )
            )
        })
    )
}
