# appendHelp <- function(colName) {
#     htmltools::tagList(
#         colName,
#         htmltools::tags$a(
#             href = "#",
#             class = "column-help",
#             `data-column` = colName,
#             "?",
#             style = "margin-left: 5px; color: blue; text-decoration: none; font-weight: bold;"
#         )
#     )
# }

helpIcon <- function(inputId) {
   shiny::actionLink(
       inputId = inputId,
       label = bsicons::bs_icon("question-circle")
   ) 
}

getColNameTags <- function(dat) {
    col_names <- list(
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
    col_names <- col_names[colnames(dat)]
    th_tags <- unname(purrr::imap(col_names, ~ {
        htmltools::tags$th(
            title = .x,
            .y
        )
    }))
    return(th_tags)
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

