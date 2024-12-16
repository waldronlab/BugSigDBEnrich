bugphyzzNavPanel <- function(b) {
    bslib::nav_panel(
        "Bugphyzz",
        value = 'bugphyzz_panel',
        htmltools::br(),
        bugphyzzOptions(),
        shiny::tags$hr(),
        # htmltools::h3("Analysis options"),
        # semanticAnalysisButton(),
        # shiny::tags$hr(),
        htmltools::h3("Actions"),
        actionButtons(),
        shiny::tags$hr(),
        
        shiny::uiOutput("result_header_bp"),
        shiny::uiOutput("rank_warning_bp"),
        shiny::uiOutput("res_bp")
    ) 
}

bugphyzzOptions <- function() {
    list(
        shinyWidgets::pickerInput(
            inputId = "bugphyzz_attributes",
            label = list("Attributes: ", helpIcon("bugphyzz_attributes_help")),
            choices = NULL, 
            selected = NULL,
            multiple = TRUE,
            options = list(
                `actions-box` = TRUE,
                `live-search` = TRUE,
                `selected-text-format` = "count > 1",
                countSelectedText = "{0} attributes selected",
                title = "Select attributes"
            )
        ),
        shiny::radioButtons(
            inputId = "bugphyzz_type",
            label = list("Identifier type:", helpIcon("bugphyzz_type_help")),
            choices = c("ncbi", "taxname", "metaphlan"),
            selected = "ncbi",
            inline = TRUE
        ),
        shiny::checkboxGroupInput(
            inputId = "bugphyzz_rank",
            label = list("Taxonomic rank(s):", helpIcon("bugphyzz_rank_help")),
            choices = rankOptions("bugphyzz"),
            inline = TRUE
        ),
        shiny::checkboxInput(
            inputId = "bugphyzz_rank_mixed",
            label = "(De)Select all",
            value = TRUE
        ),
        shiny::checkboxGroupInput(
            inputId = "bugphyzz_evidence",
            label = list("Evidence:", helpIcon("bugphyzz_evidence_help")),
            choices = bugphyzzEvidenceOptions(),
            inline = TRUE
        ),
        shiny::checkboxInput(
            inputId = "bugphyzz_evidence_mixed",
            label = "(De)Select all",
            value = TRUE
        ),
        shiny::checkboxGroupInput(
            inputId = "bugphyzz_frequency",
            label = list("Frequency:", helpIcon("bugphyzz_frequency_help")),
            choices = bugphyzzFrequencyOptions(),
            inline = TRUE
        ),
        shiny::checkboxInput(
            inputId = "bugphyzz_frequency_mixed",
            label = "(De)Select all",
            value = TRUE
        ),
        shiny::numericInput(
            inputId = "bugphyzz_min", 
            label = list("Minimum size:", helpIcon("bugphyzz_min_help")),
            value = 5,
            min = 1,
            max = 100,
            step = 1
        )
        
    )
}

bugphyzzEvidenceOptions <- function() {
    c("exp", "igc", "tas", "nas", "tax", "asr")
}

bugphyzzFrequencyOptions <- function() {
    c("always", "usually", "sometimes", "unknown")
}
