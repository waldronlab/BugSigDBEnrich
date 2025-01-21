sets2Df <- function(inputSigFun, y, input) {
    x <- inputSigFun()
    
    # if (isType(x, "metaphlan")[[1]] && input$options_tab == "bugphyzz_panel") {
    if (isType(x, "metaphlan")[[1]] && input$dbselect == "bugphyzz_panel") {
        # names(x) <- x
        x <- x |> 
            stringr::str_extract("[^|]+$") |> 
            stringr::str_remove("^[a-zA-Z]__")
    } 
    
    input_only <- setdiff(x, y)
    both <- intersect(x, y)
    target_only <- setdiff(y, x)
    
    ids <- c(input_only, both, target_only)
    
    labels <- dplyr::case_when(
        ids %in% input_only ~ "Input only",
        ids %in% both ~ "Both",
        ids %in% target_only ~ "Database only"
    )
    df <- data.frame(
        ID = ids,
        Label = labels
    )
    ncbi_path <- cacheTaxonomizr::txPath()
    
    if (isType(x, "ncbi")[[1]]) {
        df <- df |> 
            dplyr::mutate(
                `Taxon name` = id2name(.data$ID)
            ) |> 
            dplyr::relocate(.data$`Taxon name`, .after = .data$ID) |> 
            dplyr::rename(`NCBI ID` = .data$ID) |> 
            dplyr::mutate(
                `NCBI ID` = .data$`NCBI ID` |> 
                    strsplit(",") |> 
                    purrr::map(
                        ~ paste0(
                            '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
                            .x,'" target="_blank">', .x, '</a>'
                        ) |> 
                            paste(collapse = ",")
                    )
            )
    } else if (isType(x, "taxname")[[1]]) {
        df <- df |> 
            dplyr::mutate(
                `NCBI ID` = taxonomizr::getId(.data$ID, ncbi_path)
            ) |> 
            dplyr::relocate(.data$`NCBI ID`, .after = .data$ID) |> 
            dplyr::rename(`Taxon name` = .data$ID) |> 
            dplyr::mutate(
                `NCBI ID` = .data$`NCBI ID` |> 
                    strsplit(",") |> 
                    purrr::map(
                        ~ paste0(
                            '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
                            .x,'" target="_blank">', .x, '</a>'
                        ) |> 
                            paste(collapse = ",")
                    )
            )
    } else if (isType(x, "metaphlan")[[1]]) {
        df <- df |> 
            dplyr::mutate(
                `NCBI ID` = .data$ID |> 
                    stringr::str_extract("[^|]+$") |>
                    stringr::str_remove("^[a-zA-Z]__") |>
                    taxonomizr::getId(ncbi_path)
            ) |> 
            dplyr::relocate(.data$`NCBI ID`, .after = .data$ID) |> 
            dplyr::rename(`Metaphlan name` = .data$ID) |> 
            dplyr::mutate(
                `NCBI ID` = .data$`NCBI ID` |> 
                    strsplit(",") |> 
                    purrr::map(
                        ~ paste0(
                            '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=',
                            .x,'" target="_blank">', .x, '</a>'
                        ) |> 
                            paste(collapse = ",")
                    )
            )
    }
     
    return(df)
}

helpIcon <- function(inputId) {
    shiny::actionLink(
        inputId = inputId,
        label = bsicons::bs_icon("question-circle")
    ) 
}

id2name <- function(x) {
    ncbi_path <- cacheTaxonomizr::txPath()
    taxonomizr::getCommon(x, ncbi_path) |> 
        purrr::map_chr(~ {
            if (is.null(.x)) {
                return(NA)
            } else {
                name <- .x |> 
                    dplyr::filter(.data$type == "scientific name") |> 
                    dplyr::pull(.data$name)
                return(name)
            }
        })
}

helpPageDiv <- function(x, hash = FALSE) {
    URL <- "https://github.com/waldronlab/BugSigDBEnrich/blob/devel/inst/www/help.md"
    if (!is.null(hash)) {
        URL <- stringr::str_c(URL, "#", hash)
    }
    stringr::str_c(
        '<a href="', URL, '" target="_blank">', x, '</a>'
    )
}


urlHandlerServer <- function(session) {
    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query$tab)) {
            shiny::updateNavbarPage(session, "navbar", selected = query$tab)
        }
    }) 
}

httpGetHandler <- function(
        query, session, input, output, inputSigFun, bsdb, b, dat, open_tabs, sigs_rval
) {
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
                output$res <-  shiny::renderUI({
                    shiny::tabsetPanel(
                        id = "main_tabs",
                        shiny::tabPanel(
                            title = "Table",
                            htmltools::div(
                                id = "table-container",
                                DT::DTOutput("result_table")
                            )
                        )
                    )
                })
                bsdbResult(input, output, inputSigFun, bsdb, dat, sigs_rval)
                hasRun(TRUE)  # Set the flag to indicate the analysis has run
            }
        }
    })
    shiny::observeEvent(input$run_analysis, {
        shiny::req(input$text_input)
        
        output$result_header <- shiny::renderUI(NULL)
        output$res <- shiny::renderUI(NULL)
        
        output$res <-  shiny::renderUI({
            shiny::tabsetPanel(
                id = "main_tabs",
                shiny::tabPanel(
                    title = "Table",
                    htmltools::div(
                        id = "table-container",
                        DT::DTOutput("result_table")
                    )
                )
            )
        })
        
        dat(data.frame())
        open_tabs(list())
        sigs_rval(list())
        
        # if (input$options_tab == "bugsigdb_panel") {
        if (input$dbselect == "bugsigdb_panel") {
            bsdbResult(input, output, inputSigFun, bsdb, dat, sigs_rval)
        # } else if (input$options_tab == "bugphyzz_panel") {
        } else if (input$dbselect == "bugphyzz_panel") {
            bugphyzzResult(input, output, inputSigFun, b, dat, sigs_rval)
        }
        
        # if (input$options_tab == "bugsigdb_panel") {
        #     bsdbResult(input, output, inputSigFun, bsdb)
        # } else if (input$options_tab == "bugphyzz_panel") {
        #     output$result_header <- shiny::renderUI({
        #         htmltools::div("Placeholder.")
        #     })
        # }
    })
}

helpModal <- function(title, message)  {
    shiny::showModal(shiny::modalDialog(
        title = title,
        htmltools::HTML(message),
        footer = shiny::modalButton("Close", shiny::icon("times")),
        easyClose = TRUE
    ))
}

getColNameTags <- function(dat) {
    cols <- list(
        ## Columns common to bugphyzz and bsdb results
        Signature = stringr::str_c(
            "Signature name. Click on them to see overlaps. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        BM25 = stringr::str_c(
            "BM25 ranking. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        JI = stringr::str_c(
            "The Jaccard index (JI) shows how similar two signatures are by",
            " comparing shared elements to total elements. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        OC = stringr::str_c(
            "The overlap coefficient (OC) measures how much one signature fits within the other. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        OCPer = stringr::str_c(
            "Overlap coefficient (OC) percentile (%) based on BSDB comparisons. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        SemSim = stringr::str_c(
            "Semantic similarity. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        Size = stringr::str_c(
            "Number of taxa in the database signature. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        ## Column only present in bsdb results
        Study = stringr::str_c(
            "The source Study of the signature.", 
            " Click on it to be re-directed to the study's curation page on BugSigDB. ",
            helpPageDiv("More...", hash = "restable")
            # "<a href='?tab=help&anchor=#results' target='_blank'> More...</a>"
        ),
        SigLink = stringr::str_c(
            "Signature link. Click on it to be re-directed to the signature's page on BugSigDB. ",
            helpPageDiv("More...", hash = "restable")
        )
    )
    cols[colnames(dat)] |> 
        purrr::imap(~ htmltools::tags$th(title = .x, .y)) |> 
        unname()
}

get_per <- function(x) {
    purrr::map_int(x, ~ {
        if (.x <= 0) {
            return(0)
        }
        as.integer(sub("%", "", names(per)[max(which(.x >= per))]))
    })
}

appendDTDeps <- function() {
    list(
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
                function initializeTooltips() {
                  // Dispose of existing tooltips
                  const tooltipTriggerList = document.querySelectorAll('#table-container th[title]');
                  tooltipTriggerList.forEach(element => {
                      const existingTooltip = bootstrap.Tooltip.getInstance(element);
                      if (existingTooltip) {
                          existingTooltip.dispose();
                      }
                      // Initialize new tooltips
                      new bootstrap.Tooltip(element, {
                          html: true,
                          trigger: 'manual',
                          placement: 'top'
                      });
                  });

                  // Add hover logic
                  tooltipTriggerList.forEach(element => {
                      const tooltip = bootstrap.Tooltip.getInstance(element);
                      let isOverElement = false;
                      let isOverTooltip = false;

                      element.addEventListener('mouseenter', () => {
                          isOverElement = true;
                          tooltip.show();
                      });

                      element.addEventListener('mouseleave', () => {
                          isOverElement = false;
                          setTimeout(() => {
                              if (!isOverElement && !isOverTooltip) {
                                  tooltip.hide();
                              }
                          }, 100);
                      });

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
                              setTimeout(() => {
                                  if (!isOverElement && !isOverTooltip) {
                                      tooltip.hide();
                                  }
                              }, 100);
                          }
                      });
                  });
                }
              </script>"
        )
    )
}

# 
# appendDTDeps <- function() {
#     list(
#         htmltools::htmlDependency(
#             name = "tooltip-init",
#             version = "1.0.0",
#             src = c(file = tempdir()),
#             head = "
#               <style>
#               .tooltip {
#                 pointer-events: auto !important;
#               }
#               .tooltip a {
#                 color: #fff;
#                 text-decoration: underline;
#               }
#               </style>
#               <script>
#                 $(document).ready(function() {
#                   const tooltipTriggerList = document.querySelectorAll('#table-container th[title]');
#                   tooltipTriggerList.forEach(element => {
#                     const tooltip = new bootstrap.Tooltip(element, {
#                       html: true,
#                       trigger: 'manual',
#                       placement: 'top'
#                     });
#                     
#                     let isOverElement = false;
#                     let isOverTooltip = false;
#                     
#                     element.addEventListener('mouseenter', () => {
#                       isOverElement = true;
#                       tooltip.show();
#                     });
#                     
#                     element.addEventListener('mouseleave', () => {
#                       isOverElement = false;
#                       setTimeout(() => {
#                         if (!isOverElement && !isOverTooltip) {
#                           tooltip.hide();
#                         }
#                       }, 100);
#                     });
#                     
#                     document.addEventListener('mouseover', (e) => {
#                       const tooltipEl = document.querySelector('.tooltip');
#                       if (tooltipEl && tooltipEl.contains(e.target)) {
#                         isOverTooltip = true;
#                       }
#                     });
#                     
#                     document.addEventListener('mouseout', (e) => {
#                       const tooltipEl = document.querySelector('.tooltip');
#                       if (tooltipEl && !tooltipEl.contains(e.target)) {
#                         isOverTooltip = false;
#                         setTimeout(() => {
#                           if (!isOverElement && !isOverTooltip) {
#                             tooltip.hide();
#                           }
#                         }, 100);
#                       }
#                     });
#                   });
#                 });
#               </script>"
#         )
#     )
# }
# 





