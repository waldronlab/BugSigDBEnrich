
# Input -------------------------------------------------------------------
inputSignature <- function(input) {
    shiny::reactive({
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        
        if (cond1) {
            inputSig <- unlist(strsplit(input$text_input, "\n"))
            inputSig <- inputSig[inputSig != ""]
        } else if (cond2) {
            inputSig <- switch(
                tools::file_ext(input$file_input$name),
                txt = readLines(con = input$file_input$datapath),
                shiny::validate("Invalid file. Please upload a .txt file")
            )
        } else {
            shiny::showNotification("❌ No input.", type = "error")
            shiny::req(FALSE)
        }
        return(inputSig)
    })
}

whichType <- function(x) {
    dplyr::case_when(
        stringr::str_detect(x, "^\\d+$") ~ "ncbi",
        stringr::str_detect(x, "^[a-zA-Z]{1}__.*?(\\|[a-zA-Z]{1}__.*?)*$") ~ "metaphlan",
        stringr::str_detect(x, "^.+$") ~ "taxname",
        is.na(x) ~ NA
    )
}

isType <- function(input_sig, input_type) {
    whichType(input_sig) == input_type
}

# Example text ------------------------------------------------------------
generateExampleText <- function(x) {
    paste(exampleSigs[[x]], collapse = "\n")
}

textBoxExamplesServer <- function(input, session) {
    shiny::observeEvent(input$ncbi_box, {
        shiny::updateTextInput(
            session = session,
            inputId = "text_input",
            value = generateExampleText("ncbi")
        )
    })
    shiny::observeEvent(input$taxname_box, {
        shiny::updateTextInput(
            session = session, 
            inputId = "text_input",
            value = generateExampleText("taxname")
        )
    })
    shiny::observeEvent(input$metaphlan_box, {
        shiny::updateTextInput(
            session = session,
            inputId =  "text_input",
            value = generateExampleText("metaphlan")
        )
    }) 
    shiny::observeEvent(input$badsig_box, {
        shiny::updateTextInput(
            session = session, 
            inputId = "text_input",
            value = generateExampleText("badsig")
        )
    })
}

# Example files -----------------------------------------------------------

getExamplePaths <- function() {
    ncbi <- system.file(
        "extdata", "ncbi.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    taxname <- system.file(
        "extdata", "taxname.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    metaphlan <- system.file(
        "extdata", "metaphlan.txt", package = "BugSigDBEnrich", mustWork = TRUE
    )
    list(
        ncbi = ncbi,
        taxname = taxname,
        metaphlan = metaphlan
    )
}

fileInputExamplesServer <- function(output) {
    output$downloadExampleNCBI <- shiny::renderUI({
        shiny::downloadLink("ncbiDownload", "ncbi")
    })
    output$downloadExampleTaxname <- shiny::renderUI({
        shiny::downloadLink("taxnameDownload", "taxname")
    })
    output$downloadExampleMetaphlan <- shiny::renderUI({
        shiny::downloadLink("metaphlanDownload", "metaphlan")
    })
    output$ncbiDownload <- shiny::downloadHandler(
        filename = function() "ncbi.txt",
        content = function(file) file.copy(getExamplePaths()$ncbi, file)
    )
    output$taxnameDownload <- shiny::downloadHandler(
        filename = function() "taxname.txt",
        content = function(file) file.copy(getExamplePaths()$taxname, file)
    )
    output$metaphlanDownload <- shiny::downloadHandler(
        filename = function() "metaphlan.txt",
        content = function(file) file.copy(getExamplePaths()$metaphlan, file)
    )
}


# Help --------------------------------------------------------------------
inputHelp <- function(input) {
    list(
        shiny::observeEvent(input$inputtext_help_link, {
            helpModal(
                "Enter list of NCBI taxids, taxon names, or metaphlan names",
                htmltools::HTML(
                    stringr::str_c(
                        "Enter a list of IDs; one per line.",
                        " The IDs can be in 'ncbi', 'taxname', or 'metaphlan' format.",
                        " Cick on the examples below to fill the text box with sample IDs. ",
                        helpPageDiv("More...", "input")
                        # "<a href='?tab=help&anchor=#input' target='_blank'>More...</a>"
                    )
                )
            )
        }),
        shiny::observeEvent(input$inputfile_help_link, {
            helpModal(
                "Upload a file:",
                htmltools::HTML(
                    stringr::str_c(
                        "A text file with '.txt' extension containing one ID per line.",
                        " Click on the examples below to download a sample file. ",
                        helpPageDiv("More...", "input")
                        # "<a href='?tab=help&anchor=#input' target='_blank'>More...</a>"
                    )
                )
            )
        })
    )
}

# Check ranks -------------------------------------------------------------
checkRanks <- function(input, inputSig, db) {
    id_type <- paste0(db, "_type")
    id_rank <- paste0(db, "_rank")
    if (input[[id_type]] == "ncbi") {
        ranks <- inputSig |> 
            getRank()
    } else if (input[[id_type]] == "taxname") {
        ranks <- inputSig |> 
            getTaxIDs() |> 
            getRank()
    } else if (input[[id_type]] == "metaphlan") {
        ranks <- inputSig |> 
            stringr::str_extract("[^|]+$") |> 
            stringr::str_remove("^[a-zA-Z]__") |> 
            getTaxIDs() |> 
            getRank()
    }
    names(ranks) <- inputSig
    lgl_vct <- ranks %in% input[[id_rank]]
    if (!all(lgl_vct)) {
        shiny::showNotification(
            stringr::str_c(
                "⚠ Mismatching ranks. ",
                sum(!lgl_vct),  " taxa have a rank mismatching the selected options.",
                " Check which taxa they are in the results header."
            ),
            duration = 10,
            type = "warning"
        )
        return(ranks[!lgl_vct])
        # shiny::req(FALSE)
    } else {
        return(NULL)
    }
}

getRank <- function(ids) {
    ranks <- rankOptions("bugphyzz") # NCBI uses bugphyzz tax level names
    path <- cacheTaxonomizr::txPath()
    taxonomy <- withCallingHandlers(
        warning = function(w) invokeRestart("muffleWarning"),
        expr =  taxonomizr::getRawTaxonomy(ids, path)
    )
    lgl <- !purrr::map_lgl(taxonomy, ~ all(is.na(.x)))
    purrr::map_if(
        .x = taxonomy,
        .p = lgl,
        .f = ~ {
            rks <- .x[ranks]
            rks <- rks[!is.na(rks)]
            names(rks)[length(rks)]
        }
    ) |> 
        purrr::map_chr(~ {
            if (!length(.x)) {
                return(NA)
            } else {
                return(.x)
            }
        }) |> 
        unname()
}

getTaxIDs <- function(x) {
    path <- cacheTaxonomizr::txPath()
    myIds <- withCallingHandlers(
        warning = function(w) invokeRestart("muffleWarning"),
        expr = taxonomizr::getId(x, sqlFile = path)
    )
    myIds |> 
        strsplit(",") |> 
        purrr::map_chr( ~{
            if (length(.x) > 1) {
                return(getProk(.x))
            } else {
                return(.x)
            }
        })
    return(myIds)
}

getProk <- function(x) {
    path <- cacheTaxonomizr::txPath()
    taxonomizr::getRawTaxonomy(x, path) |> 
        purrr::keep(~ {
            sk <- .x[["superkingdom"]]
            sk %in% c("Bacteria", "Archaea")
        }) |> 
        names() |> 
        stringr::str_trim()
}
