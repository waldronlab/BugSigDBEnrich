
inputTextHelp <- function(input) {
    shiny::observeEvent(input$inputtext_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Enter list of NCBI taxids, taxon names, or metaphlan names",
            htmltools::HTML(
                stringr::str_c(
                    "Enter a list of IDs; one per line.",
                    " The IDs can be in 'ncbi', 'taxname', or 'metaphlan' format.",
                    " Cick on the examples below to fill the text box with sample IDs.",
                    "<a href='?tab=help&anchor=input' target='_blank'> More...</a>"
                )
            ),
            easyClose = TRUE
        ))
    })
}

inputFileHelp <- function(input) {
    shiny::observeEvent(input$inputfile_help_link, {
        shiny::showModal(shiny::modalDialog(
            title = "Upload a file:",
            htmltools::HTML(
                stringr::str_c(
                    "A text file with '.txt' extension containing one ID per line.",
                    " Click on the examples below to download a sample file.",
                    "<a href='?tab=help&anchor=input' target='_blank'> More...</a>"
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
                    "Type of the target signatures in BugSigDB.",
                    " The type must match the input IDs.",
                    "<a href='?tab=help&anchor=options' target='_blank'> More...</a>"
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
                    "Select the rank(s) of the taxa included in the target BugSigDB signature.",
                    " Use the '(De)select all' check box to select or deselect all ranks at once.",
                    "<a href='?tab=help&anchor=options' target='_blank'> More...</a>"
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
                    "If 'Yes', only ranks manually curated will be included.",
                    " If 'No', the taxonomic tree will be cut at the specified rank (above).",
                    " Only one rank (above) can be selected when the 'No' options is used.",
                    "<a href='?tab=help&anchor=options' target='_blank'> More...</a>"
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
                    "Minimum number of IDs to filter the target BugSigDB signatures.",
                    "<a href='?tab=help&anchor=options' target='_blank'> More...</a>"
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
                    "Name of the BugSigDB signature.",
                    "<a href='?tab=help&anchor=results' target='_blank'> More...</a>"
                )
            )
        ),
        JI = list(
            title = "Jaccard Index (JI)",
            content = htmltools::HTML(
                stringr::str_c(
                    "The Jaccard Index shows how similar two signatures are by",
                    " comparing shared elements to total elements.",
                    "<a href='?tab=help&anchor=results' target='_blank'> More...</a>"
                )
            )
        ),
        OC = list(
            title = "Overlap coefficient (OC)",
            content = htmltools::HTML(
                stringr::str_c(
                    "The Overlap Coefficient measures how much one signature fits within the other",
                    "<a href='?tab=help&anchor=results' target='_blank'> More...</a>"
                )
            )
        ),
        Size = list(
            title = "Size",
            content = htmltools::HTML(
                stringr::str_c(
                    "Number of taxa in the target BugSigDB signature.",
                    "<a href='?tab=help&anchor=results' target='_blank'> More...</a>"
                )
            )
        ),
        Study = list(
            title = "Study",
            content = htmltools::HTML(
                stringr::str_c(
                    "The source Study of the signature.", 
                    " Click on it to be re-directed to the study's curation page in BugSigDB.",
                    "<a href='?tab=help&anchor=results' target='_blank'> More...</a>"
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
