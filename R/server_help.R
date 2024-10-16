
inputTextHelp <- function(input) {
    shiny::observeEvent(input$inputtext_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Eneter list of NCBI taxids, taxon names, or metaphlan names",
            "placeholder",
            footer = tagList(
                shiny::actionButton("close_modal", "Close"),
                htmltools::tags$a(
                    href = "?tab=help&anchor=input", "more...",
                    target = "_blank"
                )
            )
        ))
    })
}

inputFileHelp <- function(input) {
    shiny::observeEvent(input$inputfile_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Or upload a file:",
            "placeholder",
            footer = tagList(
                shiny::actionButton("close_modal", "Close"),
                htmltools::tags$a(
                    href = "?tab=help&anchor=input", "more...",
                    target = "_blank"
                )
            )
        ))
    })
}
typeHelp <- function(input) {
    shiny::observeEvent(input$type_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Identifier type",
            "placeholder",
            footer = tagList(
                shiny::actionButton("close_modal", "Close"),
                htmltools::tags$a(
                    href = "?tab=help&anchor=options", "more...",
                    target = "_blank"
                )
            )
        ))
    })
}

rankHelp <- function(input) {
    shiny::observeEvent(input$rank_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Select taxonomic rank(s)",
            stringr::str_c(
                "Signatures will contain taxa of all the ranks selected",
                " (if recorded by a curator).",
                " Use the (De)select check box to select or deselect all ranks."
            ),
            footer = tagList(
                shiny::actionButton("close_modal", "Close"),
                htmltools::tags$a(
                    href = "?tab=help&anchor=options", "more...",
                    target = "_blank"
                )
            )
        ))
    })
}

exactHelp <- function(input) {
    shiny::observeEvent(input$exact_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Use exact taxonomic level",
            stringr::str_c(
                "Signatures will contain taxa of all the ranks selected",
                " (if recorded by a curator).",
                " Use the (De)select check box to select or deselect all ranks."
            ),
            footer = tagList(
                shiny::actionButton("close_modal", "Close"),
                htmltools::tags$a(
                    href = "?tab=help&anchor=options", "more...",
                    target = "_blank"
                )
            )
        ))
    })
}

minsizeHelp <- function(input) {
    shiny::observeEvent(input$minsize_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Minimum signature size",
            stringr::str_c(
                "Signatures will contain taxa of all the ranks selected",
                " (if recorded by a curator).",
                " Use the (De)select check box to select or deselect all ranks."
            ),
            footer = tagList(
                shiny::actionButton("close_modal", "Close"),
                htmltools::tags$a(
                    href = "?tab=help&anchor=options", "more...",
                    target = "_blank"
                )
            )
        ))
    })
}