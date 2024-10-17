## HTTR GET handler
httpGetHandler <- function(query, session, input, output, inputSigFun, bsdb) {
    hasRun <- shiny::reactiveVal(FALSE)

    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query$vector)) {
            prefill_vector <- strsplit(query$vector, ",")[[1]]
            shiny::updateTextInput(
                session, "text_input",
                value = paste(prefill_vector, collapse = "\n")
            )
            detectedType <- unique(whichType(prefill_vector))[1]
            shiny::updateRadioButtons(
                session = session, inputId = "type_selection",
                selected = detectedType
            )

            if (!hasRun()) {
                shiny::req(input$text_input)  # Ensure input is provided
                mainResult(input, output, inputSigFun, bsdb)
                hasRun(TRUE)  # Set the flag to indicate the analysis has run
            }
        }
    })

    shiny::observeEvent(input$run_analysis, {
        shiny::req(input$text_input)  # Ensure input is provided
        mainResult(input, output, inputSigFun, bsdb)
    })
    # shiny::observe({
    #     query <- shiny::parseQueryString(session$clientData$url_search)
    #     if (!is.null(query$vector)) {
    #         prefill_vector <- strsplit(query$vector, ",")[[1]]
    #         shiny::updateTextInput(
    #             session, "text_input",
    #             value = paste(prefill_vector, collapse = "\n")
    #         )
    #         detectedType <- unique(whichType(prefill_vector))[1] # select only the first to prevent errors.
    #         shiny::updateRadioButtons(
    #             session = session, inputId = "type_selection",
    #             selected = detectedType
    #         )
    #         shiny::req(input$text_input)
    #         mainResult(input, output, inputSigFun, bsdb)
    #     }
    # })
}
