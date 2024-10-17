
inputTextHelp <- function(input) {
    shiny::observeEvent(input$inputtext_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Enter list of NCBI taxids, taxon names, or metaphlan names",
            htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=input' target='_blank'>More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}

inputFileHelp <- function(input) {
    shiny::observeEvent(input$inputfile_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Or upload a file:",
            htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=input' target='_blank'>More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}
typeHelp <- function(input) {
    shiny::observeEvent(input$type_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Identifier type",
            htmltools::HTML(
                stringr::str_c(
                    "placeholder. ",
                    "<a href='?tab=help&anchor=options' target='_blank'>More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}

rankHelp <- function(input) {
    shiny::observeEvent(input$rank_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Select taxonomic rank(s)",
            htmltools::HTML(
                stringr::str_c(
                    "placeholder. ",
                    "<a href='?tab=help&anchor=options' target='_blank'>More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}

exactHelp <- function(input) {
    shiny::observeEvent(input$exact_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Use exact taxonomic level",
            htmltools::HTML(
                stringr::str_c(
                    "placeholder. ",
                    "<a href='?tab=help&anchor=options' target='_blank'>More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}

minsizeHelp <- function(input) {
    shiny::observeEvent(input$minsize_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Minimum signature size",
            htmltools::HTML(
                stringr::str_c(
                    "placeholder. ",
                    "<a href='?tab=help&anchor=options' target='_blank'>More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}

tableHelp <- function(input) {
    help_info <- list(
        Signature = list(
            title = "Signature",
            content = htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=results' target='_blank'>More...</a>"
                )
            )
        ),
        JI = list(
            title = "Jaccard Index (JI)",
            content = htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=results' target='_blank'>More...</a>"
                )
            )
        ),
        OC = list(
            title = "Overlap coefficient (OC)",
            content = htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=results' target='_blank'>More...</a>"
                )
            )
        ),
        Size = list(
            title = "Size",
            content = htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=results' target='_blank'>More...</a>"
                )
            )
        ),
        Study = list(
            title = "Study",
            content = htmltools::HTML(
                stringr::str_c(
                    "Placeholder. ",
                    "<a href='?tab=help&anchor=results' target='_blank'>More...</a>"
                )
            )
        )
    )
    
    observeEvent(input$help_clicked, {
        col <- input$help_clicked
        info <- help_info[[col]]
        if (is.null(info)) {
            info <- list(
                title = paste("Help for column:", col),
                content = paste(
                    "This is where you would put help information for the column", col
                )
            )
        }
        
        showModal(modalDialog(
            title = info$title,
            info$content,
            easyClose = TRUE
        ))
    })
}
