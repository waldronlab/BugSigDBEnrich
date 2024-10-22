textInputBox <- function() {
    shiny::textAreaInput(
        inputId = "text_input",
        label = list(
            "Enter list of NCBI taxids, taxon names, or metaphlan names:",
            shiny::actionLink(
                "inputtext_help_link",
                label = bsicons::bs_icon("question-circle")
            )
        ),
        height = '200px',
        width = "500px",
        resize = "both"
    )
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
        ),
        htmltools::div(
            style = "display: inline-block; margin-right: 10px;",
            shiny::actionLink("badsig_box", "badsig")
        )
    )
}

fileInputBox <- function() {
    shiny::fileInput(
        inputId = "file_input",
        label = list(
            "Or upload a file:",
            shiny::actionLink(
                "inputfile_help_link",
                label = bsicons::bs_icon("question-circle")
            )
        ),
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