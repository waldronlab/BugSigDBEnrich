resetApp <- function(input, session) {
    shiny::observeEvent(input$resetButton, {
        session$sendCustomMessage("resetURL", list())
        session$reload()
    })
}