bugphyzzOptionsServer <- function(input, session, b) {
    list(
        shiny::observe({
            shiny::updateSelectInput(
                session = session,
                inputId = "bugphyzz_attributes",
                choices =  c("select all", sort(names(b)))
            )
        }),
        shiny::observeEvent(input$bugphyzz_attributes, {
            if ("select all" %in% input$bugphyzz_attributes) {
                shiny::updateSelectizeInput(
                    session = session,
                    inputId = "bugphyzz_attributes",
                    selected = sort(names(b))
                )
            }
        }),
        shiny::observeEvent(input$bugphyzz_rank_mixed, {
            if (input$bugphyzz_rank_mixed) {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_rank",
                    selected = rankOptions("bugphyzz")
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_rank",
                    selected = character(0)
                )
            }
        }),
        shiny::observeEvent(input$bugphyzz_evidence_mixed, {
            if (input$bugphyzz_evidence_mixed) {
                shiny::updateCheckboxGroupInput(
                    session = session, 
                    inputId = "bugphyzz_evidence",
                    selected = bugphyzzEvidenceOptions()
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_evidence",
                    selected = character(0)
                )
            }
        }),
        shiny::observeEvent(input$bugphyzz_frequency_mixed, {
            if (input$bugphyzz_frequency_mixed) {
                shiny::updateCheckboxGroupInput(
                    session = session, 
                    inputId = "bugphyzz_frequency",
                    selected = bugphyzzFrequencyOptions()
                )
            } else {
                shiny::updateCheckboxGroupInput(
                    session = session,
                    inputId = "bugphyzz_frequency",
                    selected = character(0)
                )
            }
        })
    )
}
