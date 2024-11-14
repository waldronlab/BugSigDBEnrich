bugphyzzOptionsHelp <- function(input) {
    list(
        shiny::observeEvent(input$bugphyzz_attributes_help, {
            helpModal(
                "Attributes",
                stringr::str_c(
                    "Select one or more bugphyzz attributes. ",
                    "<a href='?tab=help&anchor=#options' target='_blank'>More...</a>"
                )
            )
        })
    )
}