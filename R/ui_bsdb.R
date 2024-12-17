
bsdbNavPanel <- function() {
    bslib::nav_panel(
        "BugSigDB",
        value = "bugsigdb_panel",
        htmltools::br(),
        bsdbSigOptions()
    )
}

bsdbSigOptions <- function() {
    list(
        shiny::radioButtons(
            inputId = "bsdb_type",
            label = list("Identifier type:", helpIcon("bsdb_type_help")),
            choices = c("ncbi", "taxname", "metaphlan"),
            selected = "ncbi",
            inline = TRUE
        ),
        shiny::checkboxGroupInput(
            inputId = "bsdb_rank",
            label = list("Taxonomic ranks(s):", helpIcon("bsdb_rank_help")),
            choices = rankOptions(),
            selected = rankOptions(),
            inline = TRUE
        ),
        shiny::checkboxInput(
            inputId = "bsdb_rank_mixed",
            label = "(De)Select all",
            value = TRUE
        ),
        shiny::radioButtons(
            inputId = "bsdb_exact", 
            label = list("Exact taxonomic level:", helpIcon("bsdb_exact_help")),
            choiceNames = c("Yes", "No"),
            choiceValues = c(TRUE, FALSE),
            selected = TRUE,
            inline = TRUE
        ),
        shiny::numericInput(
            inputId = "bsdb_min",
            label = list("Minimum size:", helpIcon("bsdb_min_help")),
            value = 5,
            min = 1,
            max = 100,
            step = 1
        )
    )
}

rankOptions <- function(x = "bsdb") {
    y <- list(
        bsdb = c(
            "kingdom", "phylum", "class", "order",
            "family", "genus", "species", "strain"
        ),
        bugphyzz = c(
            "superkingdom", "phylum", "class", "order",
            "family", "genus", "species", "strain"
        )
    )
    y[[x]]
}