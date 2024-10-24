createUI <- function() {
    ui <- shiny::navbarPage(
        title = paste0(
            "BugSigDBEnrich v",
            utils::packageDescription("BugSigDBEnrich")$Version
        ),
        header = htmltools::tags$head(
            htmltools::tags$link(
                rel = "shortcut icon",
                href = "https://raw.githubusercontent.com/waldronlab/BugSigDB/refs/heads/master/_resources/favicon.ico"
            )
        ),
        theme = bslib::bs_theme(version = 5, bootswatch = "spacelab"),
        analysisPanel(),
        helpPanel(),
        aboutPanel(),
        bugReportPanel()
    )
}

analysisPanel <- function() {
    shiny::tabPanel(
        title = "Analysis",
        
        urlHandler(), # For internal links to documentation
        
        htmltools::h3("Input"), #####################################
        textInputBox(), textBoxExamples(), 
        htmltools::br(),
        fileInputBox(), fileExamples(),
        shiny::tags$hr(),
        
        htmltools::h3("Options"), ############################
        bslib::navset_underline(
            bslib::nav_panel(
                "BugSigDB",
                htmltools::br(),
                bsdbSigOptions(),
                deactivateExactNo()
            ),
            bslib::nav_panel(
                "bugphyzz",
                htmltools::br(),
                "Placeholder."
            )
        ),
        shiny::tags$hr(),
        
        htmltools::h3("Actions"), #############################################
        analyzeButton(), downloadResultButton(),
        resetButton(), cleanURLWhenResetApp(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        htmltools::div(
            id = "table-container",
            DT::DTOutput("result_table")
        )
    )
}

helpPanel <- function() {
    shiny::tabPanel(
        title = "Help",
        value = "help",
        shiny::includeMarkdown(
            system.file("www", "help.md", package = "BugSigDBEnrich")
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
    shiny::tabPanel(
        title = "About",
        shiny::includeMarkdown(
            system.file("www", "about.md", package = "BugSigDBEnrich")
        ) 
    )
}
