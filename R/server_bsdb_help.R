
bsdbSigOptionsHelp <- function(input) {
    list(
        shiny::observeEvent(input$bsdb_type_help, {
            helpModal(
                "Identifier type",
                stringr::str_c(
                    "Type of the target signatures in BugSigDB.",
                    " The type must match the input IDs. ",
                    "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bsdb_rank_help, {
            helpModal(
                "Select taxonomic rank(s)",
                stringr::str_c(
                    "Select the rank(s) of the taxa included in the target BugSigDB signature.",
                    " Use the '(De)select all' check box to select or deselect all ranks at once. ",
                    "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bsdb_exact_help, {
            helpModal(
                "Use exact taxonomiic level",
                stringr::str_c(
                    "If 'Yes', only ranks manually curated will be included.",
                    " If 'No', the taxonomic tree will be cut at the specified rank (above).",
                    " Only one rank (above) can be selected when the 'No' options is used. ",
                    "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        }),
        shiny::observeEvent(input$bsdb_min_help, {
            helpModal(
                "Minimum signature size",
                stringr::str_c(
                    "Minimum number of IDs to filter the target BugSigDB signatures. ",
                    "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        })
    )
}
