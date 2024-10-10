resetApp <- function(input, session) {
    shiny::observeEvent(input$resetButton, {
        session$reload()
    })
}