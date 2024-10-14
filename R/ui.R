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
        theme = shinythemes::shinytheme("spacelab"),
        analysisPanel(),
        helpPanel(),
        aboutPanel(),
        bugPanel()
    )
}

analysisPanel <- function() {
    shiny::tabPanel(
        title = "Analyze",
        # topButton(), topButtonAction(),
        htmltools::h3("Input"), #####################################
        textInputBox(), textBoxExamples(), 
        htmltools::br(),
        fileInputBox(), fileExamples(),
        shiny::tags$hr(),
        
        htmltools::h3("Options"), ############################
        idTypeRadioButtons(),
        selectRankCheckBox(), selectAllRanksCheckBox(),
        exactRankButton(),
        deactivateExactNo(),
        minSigSize(),
        shiny::tags$hr(),
        
        htmltools::h3("Actions"), #############################################
        analyzeButton(), downloadResultButton(),
        resetButton(), # resetButtonRedCSS(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("result_table")
    )
}

helpPanel <- function() {
    shiny::tabPanel(
        title = "Help",
        shiny::includeMarkdown(
            system.file("www", "help.md", package = "BugSigDBEnrich")
        ) 
    )
}

bugPanel <- function() {
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
