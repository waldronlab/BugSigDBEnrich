createUI <- function() {
    ui <- shiny::navbarPage(
        title = paste0(
            "BugSigDBEnrich ",
            utils::packageDescription("BugSigDBEnrich")$Version
        ),
        theme = shinythemes::shinytheme("spacelab"),
        analysisPanel(),
        helpPanel(),
        aboutPanel(),
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
        minSigSize(),
        shiny::tags$hr(),
        
        htmltools::h3("Actions"), #############################################
        analyzeButton(), downloadResultButton(),
        resetButton(), # resetButtonRedCSS(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("jaccard")
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
aboutPanel <- function() {
    shiny::tabPanel(
        title = "About",
        shiny::includeMarkdown(
            system.file("www", "about.md", package = "BugSigDBEnrich")
        ) 
        # htmltools::h2("BugSigDBEnrich"),
        # htmltools::h4(appSubtitle()),
    )
}

# createUI <- function() {
#     ui <- shiny::fluidPage(
#         
#         theme = shinythemes::shinytheme("simplex"),
#         
#         shiny::titlePanel("BugSigDBEnrich"),
#         htmltools::h4(appSubtitle()),
#         
#         topButton(), topButtonAction(),
#         
#         htmltools::h3("Input"), #####################################
#         textInputBox(), textBoxExamples(), 
#         htmltools::br(),
#         fileInputBox(), fileExamples(),
#         shiny::tags$hr(),
#         
#         htmltools::h3("Options"), ############################
#         idTypeRadioButtons(),
#         selectRankCheckBox(), selectAllRanksCheckBox(),
#         exactRankButton(),
#         minSigSize(),
#         shiny::tags$hr(),
#         
#         htmltools::h3("Actions"), #############################################
#         analyzeButton(), downloadResultButton(),
#         resetButton(), # resetButtonRedCSS(),
#         shiny::tags$hr(),
#         
#         ## Output
#         shiny::uiOutput("result_header"),
#         DT::DTOutput("jaccard")
#     )
# }
