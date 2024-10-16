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
        title = "BugSigDB",
        # topButton(), topButtonAction(),
    
        urlHandler(), # For internal links to documentation
        
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
        resetButton(), cleanURLWhenResetApp(), # resetButtonRedCSS(),
        shiny::tags$hr(),
        
        ## Output
        shiny::uiOutput("result_header"),
        DT::DTOutput("result_table")
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

urlHandler <- function() {
    htmltools::tags$head(
        htmltools::tags$script(htmltools::HTML("
      $(document).ready(function() {
        var urlParams = new URLSearchParams(window.location.search);
        var tabName = urlParams.get('tab');
        var anchor = urlParams.get('anchor');
        
        if (tabName) {
          $('a[data-value=\"' + tabName + '\"]').tab('show');
          if (anchor) {
            setTimeout(function() {
              var element = $('#' + anchor);
              if (element.length) {
                $('html, body').animate({
                  scrollTop: element.offset().top
                }, 500);
              }
            }, 300);
          }
        }
        
        // Update URL when changing tabs
        $('a[data-toggle=\"tab\"]').on('shown.bs.tab', function (e) {
          var tabName = $(e.target).attr('data-value');
          var newUrl = updateUrlParameter(window.location.href, 'tab', tabName);
          newUrl = updateUrlParameter(newUrl, 'anchor', null);
          history.pushState(null, '', newUrl);
        });
      });
      
      function updateUrlParameter(url, param, value) {
        var regex = new RegExp('([?&])' + param + '=.*?(&|$)', 'i');
        var separator = url.indexOf('?') !== -1 ? '&' : '?';
        if (url.match(regex)) {
          return value ? url.replace(regex, '$1' + param + '=' + value + '$2') : url.replace(regex, '$1').replace(/&$/, '');
        } else {
          return value ? url + separator + param + '=' + value : url;
        }
      }
    "))
    )
}
