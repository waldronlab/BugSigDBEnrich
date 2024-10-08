selectAllRanks <- function(input, session) {
    shiny::observeEvent(input$mixed_selection, {
        if (input$mixed_selection) {
            shiny::updateCheckboxGroupInput(
                session, "rank_selection", selected = rankOptions()
            )
        } else {
            shiny::updateCheckboxGroupInput(
                session, "rank_selection", selected = character(0)
            )
        }
    })
}