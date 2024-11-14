textInputBox <- function() {
    list(
        shiny::textAreaInput(
            inputId = "text_input",
            label = list(
                "Enter list of NCBI taxids, taxon names, or metaphlan names:",
                helpIcon("inputtext_help_link")
            ),
            height = '200px',
            width = "500px",
            resize = "both"
        ),
        htmltools::div(
            class = "download-example-container", "Load example text:",
            htmltools::div(class = "download-example-item", shiny::actionLink("ncbi_box", "ncbi")),
            htmltools::div(class = "download-example-item", shiny::actionLink("taxname_box", "taxname")),
            htmltools::div(class = "download-example-item", shiny::actionLink("metaphlan_box", "metaphlan")),
            htmltools::div(class = "download-example-item", shiny::actionLink("badsig_box", "badsig"))
        )
    )
}

fileInputBox <- function() {
    list(
        shiny::fileInput(
            inputId = "file_input",
            label = list("Or upload a file:", helpIcon("inputfile_help_link")),
            accept = c(".txt"),
            buttonLabel = "Browse...",
            placeholder = "No .txt file selected"
        ),
        htmltools::div(
            class = "download-example-container", "Download example files:",
            htmltools::div(class = "download-example-item", shiny::uiOutput("downloadExampleNCBI")),
            htmltools::div(class = "download-example-item", shiny::uiOutput("downloadExampleTaxname")),
            htmltools::div(class = "download-example-item", shiny::uiOutput("downloadExampleMetaphlan"))
        )
    )
}
