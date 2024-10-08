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
        resetButton(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("jaccard")
    )
}
