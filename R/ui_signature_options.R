
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
       