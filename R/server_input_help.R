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
