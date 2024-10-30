bsdbSigOptionsServer <- function(input, session) {
    list(
        shiny::observeEvent(input$bsdb_rank_mixed, {
            if (input$bsdb_rank_mixed) {
                shiny::updateCheckboxGroupInput(
                    session, "bsdb_rank", selected = rankOptions()
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session, "bsdb_rank", selected = character(0)
                )
            }
        }),
        shiny::observe({
            if (length(input$bsdb_rank) > 1)
                shiny::updateRadioButtons(
                    session, "bsdb_exact", selected = TRUE
                )
        })
    )
}
