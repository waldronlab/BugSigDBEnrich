
idTypeRadioButtons <- function() {
    shiny::radioButtons(
        inputId = "type_selection",
        label = "Select identifier type:",
        choices = c("ncbi", "taxname", "metaphlan"),
        selected = "ncbi",
        inline = TRUE
    )
}

selectRankCheckBox <- function() {
    shiny::checkboxGroupInput(
        inputId = "rank_selection", 
        label = "Select identifier rank(s):",
        choices = rankOptions(),
        inline = TRUE
        # selected = c("species")
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
        label = "Use exact taxonomic level:",
        # choices = c("Yes", "No"),
        choiceNames = c("Yes", "No"),
        choiceValues = c(TRUE, FALSE),
        # selected = "Yes",
        selected = TRUE,
        inline = TRUE
    )
}

minSigSize <- function() {
    shiny::numericInput(
        inputId = "min_selection", 
        label = "Minimum signature size:", 
        value = 5,
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
