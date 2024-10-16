textInputBox <- function() {
    shiny::textAreaInput(
        inputId = "text_input",
        label = htmltools::tagList(
            "Eneter list of NCBI taxids, taxon names, or metaphlan names:",
            htmltools::tags$span(
                shiny::actionLink("inputtext_help_link", label = "?"),
                style = "cursor: pointer; color:blue; text-decoration: underline;"
            )
        ),
        height = '200px',
        width = "500px"
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
        label = htmltools::tagList(
            "Or upload a file:",
            htmltools::tags$span(
                shiny::actionLink("inputfile_help_link", label = "?"),
                style = "cursor: pointer; color:blue; text-decoration: underline;"
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