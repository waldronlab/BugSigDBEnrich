bugphyzzInputOptionsChecks <- function(input, inputSig) {
    if (!length(input$bugphyzz_attributes)) {
        shiny::showNotification(
            "Please select at least one attribute option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
    if (!length(input$bugphyzz_rank)) {
        shiny::showNotification(
            "Please select at least one rank option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
    if (!length(input$bugphyzz_evidence)) {
        shiny::showNotification(
            "Please select at least one evidence option.",
            type = "error"
        )
        shiny::req(FALSE)
    }
    if (!length(input$bugphyzz_frequency)) {
        shiny::showNotification(
            "Please select at least one frequency option.", 
            type = "error"
        )
        shiny::req(FALSE)
    }
    # isMeta <- which("metaphlan" %in% whichType(inputSig))
    # if (length(isMeta) >= 1) {
    #     shiny::showNotification(
    #         stringr::str_c(
    #             "Metaphlan not supported for bugphyzz. ",
    #             length(isMeta), " of ", length(inputSig),
    #             " identifiers are metaphlan. Please review their id type."
    #         ),
    #         type = "error"
    #     )
    #     shiny::req(FALSE)
    # }
}