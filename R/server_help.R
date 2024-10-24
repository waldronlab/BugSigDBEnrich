
createOptionsHelpModal <- function(title, message)  {
    shiny::showModal(shiny::modalDialog(
        title = title,
        message,
        footer = shiny::modalButton("Close", shiny::icon("times")),
        easyClose = TRUE
    ))
}

inputHelp <- function(input) {
    list(
        shiny::observeEvent(input$inputtext_help_link, {
            createOptionsHelpModal(
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
            createOptionsHelpModal(
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

bsdbSigOptionsHelp <- function(input) {
    list(
        shiny::observeEvent(input$type_help_link, {
            createOptionsHelpModal(
                "Identifier type",
                htmltools::HTML(
                    stringr::str_c(
                        "Type of the target signatures in BugSigDB.",
                        " The type must match the input IDs. ",
                        "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                    )
                )
            )
        }),
        
        shiny::observeEvent(input$rank_help_link, {
            createOptionsHelpModal(
                "Select taxonomic rank(s)",
                htmltools::HTML(
                    stringr::str_c(
                        "Select the rank(s) of the taxa included in the target BugSigDB signature.",
                        " Use the '(De)select all' check box to select or deselect all ranks at once. ",
                        "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                    )
                )
            )
        }),
        
        shiny::observeEvent(input$exact_help_link, {
            createOptionsHelpModal(
                "Use exact taxonomic level",
                htmltools::HTML(
                    stringr::str_c(
                        "If 'Yes', only ranks manually curated will be included.",
                        " If 'No', the taxonomic tree will be cut at the specified rank (above).",
                        " Only one rank (above) can be selected when the 'No' options is used. ",
                        "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                    )
                )
            )
        }),
        
        shiny::observeEvent(input$minsize_help_link, {
            createOptionsHelpModal(
                "Minimum signature size",
                htmltools::HTML(
                    stringr::str_c(
                        "Minimum number of IDs to filter the target BugSigDB signatures. ",
                        "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                    )
                )
            )
        })
    )
}
