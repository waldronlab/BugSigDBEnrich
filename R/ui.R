
# Header ------------------------------------------------------------------
JS <-  system.file(
    "www", "script.js", package = "BugSigDBEnrich", mustWork = TRUE
) |> 
    readLines() |> 
    paste(collapse = "\n")

CSS <- system.file(
    "www", "style.css", package = "BugSigDBEnrich", mustWork = TRUE
) |> 
    readLines() |> 
    paste(collapse = "\n")

# Main page ---------------------------------------------------------------
createUI <- function() {
    ui <- htmltools::tagList(
        waiter::use_waiter(),
        shiny::navbarPage(
            title = paste0(
                "BugSigDBEnrich v",
                utils::packageDescription("BugSigDBEnrich")$Version
            ),
            header = htmltools::tags$head(
                htmltools::tags$link(
                    rel = "shortcut icon",
                    href = "https://raw.githubusercontent.com/waldronlab/BugSigDB/refs/heads/master/_resources/favicon.ico"
                ),
                htmltools::tags$script(htmltools::HTML(JS)),
                htmltools::tags$style(htmltools::HTML(CSS))
            ),
            theme = bslib::bs_theme(version = 5, bootswatch = "spacelab"),
            analysisPanel(),
            helpPanel(),
            aboutPanel(),
            bugReportPanel()
        )
    )
    return(ui)
}

# Panels ------------------------------------------------------------------
analysisPanel <- function() {
    shiny::tabPanel(
        title = "Analysis",
        shiny::markdown(stringr::str_c(
            'Compare your list of microbes with published microbial signatures',
            ' from <a href="https://bugsigdb.org/" target="_blank">BugSigDB</a>',
            ' or phenotypic annotation sets from <a href="https://github.com/waldronlab/bugphyzz" target="_blank">BugPhyzz</a>.',
            ' The app calculates similarity metrics, including the Jaccard',
            ' Index and Overlap Coefficient, to identify shared taxa between sets.'
        )),
        htmltools::tags$hr(),
        shiny::markdown(stringr::str_c(
            "### Getting Started  \n\n",
            "Follow these steps to try the app:  \n\n",
            "1. **Load an example**: Click the \"ncbi\" link below the text box to load a <a href=\"https://bugsigdb.org/Study_454/Experiment_1/Signature_1\" target=\"_blanck\">sample list of bacteria</a>.  \n",
            "2. **Set the ID type**: Ensure \"ncbi\" is selected as the ID type in the *Database Options*.  \n",
            "3. **Use default settings**: Leave all other options at their default values.  \n",
            "4. **Run the analysis**: Click the \"Analyze\" button in the *Actions* section.",
            "  \n\n",
            "For more details, check the <a href=\"https://github.com/waldronlab/BugSigDBEnrich/blob/devel/inst/www/help.md\" target=\"_blank\">help documentation</a>."
        )),
        htmltools::tags$hr(),
        
        htmltools::h3("Input"),
        textInputBox(), htmltools::br(), fileInputBox(), shiny::tags$hr(),
        
        htmltools::h3("Database options"),
        # optionsNavSet(),
        shinyWidgets::pickerInput(
            inputId = "dbselect",
            label =  list("Select database:", helpIcon("dbselect_help")),
            choices = c("bugsigdb_panel", "bugphyzz_panel"),
            selected =  "bugsigdb_panel"
        ),
        shiny::uiOutput("db_options"),
        
        shiny::tags$hr(),
        
        htmltools::h3("Analysis options"),
        shiny::radioButtons(
            inputId = "semantic", 
            label = list(
                "Semantic similarity (",
                shiny::icon(
                    "exclamation-triangle", class = "text-warning",
                    title = "This operation can take several minutes",
                ),
                "this can take several minutes):",
                helpIcon("semantic_help")
            ),
            choiceNames = c("Yes", "No"),
            choiceValues = c(TRUE, FALSE),
            selected = FALSE,
            inline = TRUE
        ),
        shiny::tags$hr(),
        
        htmltools::h3("Actions"),
        actionButtons(), shiny::tags$hr(),
        
        shiny::uiOutput("result_header"),
        shiny::uiOutput("rank_warning"),
        shiny::uiOutput("res")
    )
}

helpPanel <- function() {
    shiny::tabPanel(
        title = "Help",
        value = "help",
        htmltools::HTML(
            stringr::str_c(
                "Find help about this app ", helpPageDiv("here"), "."
            )
        )
    )
}

bugReportPanel <- function() {
    shiny::tabPanel(
        title = "Report a bug",
        shiny::includeMarkdown(
            system.file("www", "bug.md", package = "BugSigDBEnrich")
        ) 
    )
}

aboutPanel <- function() {
    
    # shiny::tabPanel(
    #     title = "About",
    #     shiny::includeMarkdown(
    #         system.file("www", "about.md", package = "BugSigDBEnrich")
    #     ) 
    # )
    shiny::tabPanel(
        title = "About",
        htmltools::tagList(
            shiny::includeMarkdown(
                system.file("www", "about.md", package = "BugSigDBEnrich")
            ),
            htmltools::tags$hr(), # Horizontal line to separate content
            htmltools::tags$h3("Package/app DESCRIPTION file:"), # Section header
            htmltools::tags$pre( # Render the DESCRIPTION content
                paste(
                    readLines(system.file("DESCRIPTION", package = "BugSigDBEnrich")),
                    collapse = "\n"
                )
            )
            ## Code to display description contents
        )
    )
    
    # html_content <- markdown::markdownToHTML(text = markdown_content)
    # 
    # output$markdown <- renderUI({
    #     HTML(html_content)
    # })
}

# Options tab -------------------------------------------------------------
# optionsNavSet <- function() {
#     bslib::navset_underline(
#         id = "options_tab",
#         bsdbNavPanel(),
#         bugphyzzNavPanel()
#     )
# }


# Inputs ------------------------------------------------------------------
textInputBox <- function() {
    list(
        # htmltools::div(
            # class = "input-container",
        shiny::textAreaInput(
            inputId = "text_input",
            label = list(
                "Enter list of NCBI taxids, taxon names, or metaphlan names:",
                helpIcon("inputtext_help_link")
            ),
            height = '200px',
            width = "500px",
            resize = "both"
        ),
            # htmltools::div(
                # class = "markdown-instructions",

            # )
        # ),
        htmltools::div(
            class = "download-example-container",
            "Load example text:",
            htmltools::div(class = "download-example-item", shiny::actionLink("ncbi_box", "ncbi")),
            htmltools::div(class = "download-example-item", shiny::actionLink("taxname_box", "taxname")),
            htmltools::div(class = "download-example-item", shiny::actionLink("metaphlan_box", "metaphlan"))
            # htmltools::div(class = "download-example-item", shiny::actionLink("badsig_box", "badsig"))
        )
    )
}

fileInputBox <- function() {
    list(
        shiny::fileInput(
            inputId = "file_input",
            label = list("Or upload a file:", helpIcon("inputfile_help_link")),
            accept = c(".txt"),
            buttonLabel = "Browse...",
            placeholder = "No .txt file selected"
        ),
        htmltools::div(
            class = "download-example-container", "Download example files:",
            htmltools::div(class = "download-example-item", shiny::uiOutput("downloadExampleNCBI")),
            htmltools::div(class = "download-example-item", shiny::uiOutput("downloadExampleTaxname")),
            htmltools::div(class = "download-example-item", shiny::uiOutput("downloadExampleMetaphlan"))
        )
    )
}

# Action buttons ----------------------------------------------------------
actionButtons <- function() {
    list(
        shiny::actionButton(
            inputId = "analyzeButton", 
            label = "Analyze",
            icon = shiny::icon("magnifying-glass-chart")
        ),
        shiny::downloadButton(
            outputId = "downloadData",
            label = "Download result"
        ),
        shiny::actionButton(
            inputId = "resetButton", 
            label = "Reset app",
            icon = shiny::icon("refresh")
        )
    )
}
