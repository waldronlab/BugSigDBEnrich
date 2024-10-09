createUI <- function() {
    ui <- shiny::fluidPage(
        
        topButton(),
        topButtonAction(),
        
        theme = shinythemes::shinytheme("united"),
        
        shiny::titlePanel("BugSigDBEnrich"),
        htmltools::h4(appSubtitle()),
        
        htmltools::h3("Input"), #####################################
        textInputBox(),
        fileInputBox(),
        
        htmltools::div(
            style = "display: flex; align-items: center;",
            htmltools::div(
                style = "margin-right: 10px;",
                # style = "margin-right: 10px; font-weight: bold;",
                "Download example files:"
            ),
            htmltools::div(
                style = "display: inline-block; margin-right: 10px;",
                shiny::uiOutput("downloadExampleNCBI")
            ),
            htmltools::div(
                style = "display: inline-block; margin-right: 10px;",
                shiny::uiOutput("downloadExampleTaxname")
            ),
            htmltools::div(
                style = "display: inline-block; margin-right: 10px;",
                shiny::uiOutput("downloadExampleMetaphlan")
            )
        ),
        shiny::tags$hr(),
        
        htmltools::h3("Options"), ############################
        idTypeRadioButtons(),
        selectRankCheckBox(),
        selectAllRanksCheckBox(),
        exactRankButton(),
        minSigSize(),
        shiny::tags$hr(),
        
        htmltools::h3("Actions"), #############################################
        analyzeButton(),
        downloadResultButton(),
        resetButtonRedCSS(), resetButton(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("jaccard")
    )
}
