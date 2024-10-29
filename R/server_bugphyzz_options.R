bugphyzzAttributes <- function(input, session, b) {
    list(
        shiny::observe({
            shiny::updateSelectInput(
                session = session,
                inputId = "bugphyzz_attributes",
                choices =  c("select all", names(b))
            )
        }),
        shiny::observeEvent(input$bugphyzz_attributes, {
            if ("select all" %in% input$bugphyzz_attributes) {
                shiny::updateSelectizeInput(
                    session = session,
                    inputId = "bugphyzz_attributes",
                    selected = names(b)
                )
            }
        }) 
    )
    
}
