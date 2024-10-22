
idTypeRadioButtons <- function() {
    shiny::radioButtons(
        inputId = "type_selection",
        label = list("Identifier type:", helpIcon("type_help_link")),
        choices = c("ncbi", "taxname", "metaphlan"),
        selected = "ncbi",
        inline = TRUE
    )
}

selectRankCheckBox <- function() {
    shiny::checkboxGroupInput(
        inputId = "rank_selection", 
        label = list("Taxonomic ranks(s):", helpIcon("rank_help_link")),
        choices = rankOptions(),
        inline = TRUE
    )
}

selectAllRanksCheckBox <- function() {
    shiny::checkboxInput(
        inputId = "mixed_selection",
        label = "(De)Select all",
        value = TRUE
    )
}

exactRankButton <- function() {
    shiny::radioButtons(
        inputId = "exact_selection", 
        label = list("Exact taxonomic level:", helpIcon("exact_help_link")),
        choiceNames = c("Yes", "No"),
        choiceValues = c(TRUE, FALSE),
        selected = TRUE,
        inline = TRUE
    )
}

minSigSize <- function() {
    shiny::numericInput(
        inputId = "min_selection", 
        label = list("Minimum size:", helpIcon("minsize_help_link")),
        value = 1,
        min = 1,
        max = 100,
        step = 1
    )
}

rankOptions <- function() {
    c(
        "kingdom", "phylum", "class", "order",
        "family", "genus", "species", "strain"
    )
}

## Disable the use of false when two or more ranks are selected
deactivateExactNo <- function() {
    htmltools::tags$head(
        htmltools::tags$script(htmltools::HTML("
            $(document).on('shiny:inputchanged', function(event) {
                if (event.name === 'rank_selection') {
                    const checkedCount = $('input[name=\"rank_selection\"]:checked').length; 
                    if (checkedCount > 1) {
                        $('input[name=\"exact_selection\"][value=\"FALSE\"]').prop('disabled', true);
                        $('input[name=\"exact_selection\"][value=\"TRUE\"]').prop('checked', true);
                    } else {
                        $('input[name=\"exact_selection\"][value=\"FALSE\"]').prop('disabled', false);
                    }
                }
            });
        "))
    )
}
