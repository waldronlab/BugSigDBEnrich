textInputBox <- function() {
    label_text_box <- stringr::str_c(
        "Enter list of NCBI taxids, taxon names, or metaphlan names:"
    )
    shiny::textAreaInput(
        inputId = "text_input",
        label = label_text_box,
        height = '200px',
        width = "500px"
        # placeholder = generateExampleText("ncbi")
        # placeholder = c("562\n561")
    )
}

generateExampleText <- function(x) {
    paste(exampleSigs[[x]], collapse = "\n")
}

textBoxExamples <- function() {
    htmltools::div(
        style = "display: flex; align-items: center;",
        htmltools::div(
            style = "margin-right: 10px;",
            "Load example text:"
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::actionLink("ncbi_box", "ncbi"),
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::actionLink("taxname_box", "taxname"),
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::actionLink("metaphlan_box", "metaphlan")
        )
    )
    
}

fileInputBox <- function() {
    shiny::fileInput(
        inputId = "file_input",
        label = "Or upload a file:",
        accept = c(".txt"),
        buttonLabel = "Browse...",
        placeholder = "No .txt file selected"
    )
}

fileExamples <- function() {
    htmltools::div(
        style = "display: flex; align-items: center;",
        htmltools::div(
            style = "margin-right: 10px;",
            "Download example files:"
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::uiOutput("downloadExampleNCBI")
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::uiOutput("downloadExampleTaxname")
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::uiOutput("downloadExampleMetaphlan")
        )
    )
}