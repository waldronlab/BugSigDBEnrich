
urlHandlerServer <- function(session) {
    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query$tab)) {
            shiny::updateNavbarPage(session, "navbar", selected = query$tab)
        }
    }) 
}

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
                session = session, inputId = "bsdb_type",
                selected = detectedType
            )
            if (!hasRun()) {
                shiny::req(input$text_input)  # Ensure input is provided
                bsdbResult(input, output, inputSigFun, bsdb)
                hasRun(TRUE)  # Set the flag to indicate the analysis has run
            }
        }
    })
    shiny::observeEvent(input$run_analysis, {
        shiny::req(input$text_input)  # Ensure input is provided
        # bsdbResult(input, output, inputSigFun, bsdb)
        output$result_header <- renderUI({ NULL })
        output$result_table <- DT::renderDT({ data.frame() })
        
        if (input$options_tab == "bugsigdb_panel") {
            bsdbResult(input, output, inputSigFun, bsdb)
        } else if (input$options_tab == "bugphyzz_panel") {
            output$result_header <- shiny::renderUI({
                htmltools::div("Placeholder.")
            })
        }
    })
}

helpModal <- function(title, message)  {
    shiny::showModal(shiny::modalDialog(
        title = title,
        message,
        footer = shiny::modalButton("Close", shiny::icon("times")),
        easyClose = TRUE
    ))
}

getColNameTags <- function(dat) {
    cols <- list(
        Signature = stringr::str_c(
            "Name of the BugSigDB signature.",
            "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        JI = stringr::str_c(
            "The Jaccard index (JI) shows how similar two signatures are by",
            " comparing shared elements to total elements.",
            "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        OC = stringr::str_c(
            "The overlap coefficient (OC) measures how much one signature fits within the other",
            "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        Size = stringr::str_c(
            "Number of taxa in the target BugSigDB signature.",
            "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        Study = stringr::str_c(
            "The source Study of the signature.", 
            " Click on it to be re-directed to the study's curation page in BugSigDB.",
            "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        )
    )
    cols[colnames(dat)] |> 
        purrr::imap(~ htmltools::tags$th(title = .x, .y)) |> 
        unname()
}

appendDTDeps <- function(dt) {
    append(dt$dependencies, list(
        htmltools::htmlDependency(
            name = "tooltip-init",
            version = "1.0.0",
            src = c(file = tempdir()),
            head = "
          <style>
          .tooltip {
            pointer-events: auto !important;
          }
          .tooltip a {
            color: #fff;
            text-decoration: underline;
          }
          </style>
          <script>
            $(document).ready(function() {
              const tooltipTriggerList = document.querySelectorAll('#table-container th[title]');
              tooltipTriggerList.forEach(element => {
                const tooltip = new bootstrap.Tooltip(element, {
                  html: true,
                  trigger: 'manual',
                  placement: 'top'
                });
                
                let isOver = false;
                let isOverTooltip = false;
                
                element.addEventListener('mouseenter', () => {
                  isOver = true;
                  tooltip.show();
                });
                
                element.addEventListener('mouseleave', () => {
                  isOver = false;
                  setTimeout(() => {
                    if (!isOver && !isOverTooltip) {
                      tooltip.hide();
                    }
                  }, 100);
                });
                
                // Handle mouse over tooltip
                document.addEventListener('mouseover', (e) => {
                  const tooltipEl = document.querySelector('.tooltip');
                  if (tooltipEl && tooltipEl.contains(e.target)) {
                    isOverTooltip = true;
                  }
                });
                
                document.addEventListener('mouseout', (e) => {
                  const tooltipEl = document.querySelector('.tooltip');
                  if (tooltipEl && !tooltipEl.contains(e.target)) {
                    isOverTooltip = false;
                    if (!isOver) {
                      tooltip.hide();
                    }
                  }
                });
              });
            });
          </script>"
        )
    ))
}
