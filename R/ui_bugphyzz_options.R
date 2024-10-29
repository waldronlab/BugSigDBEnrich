bugphyzzNavPanel <- function(b) {
    bslib::nav_panel(
        "bugphyzz",
        value = 'bugphyzz_panel',
        htmltools::br(),
        bugphyzzOptions()
        
    ) 
}

bugphyzzOptions <- function() {
    list(
        shiny::selectizeInput( 
            inputId = "bugphyzz_attributes", 
            label = list(
                "Select attribute:",
                helpIcon("bugphyzz_attributes_help")
            ),
            choices = NULL,
            multiple = TRUE, width = "500px"
        )
    )
}