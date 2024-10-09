inputSignature <- function(input) {
    shiny::reactive({
        # shiny::req(input$text_input)
        # readBox(input$text_input)
        # 
        if (!is.null(input$text_input) && nzchar(input$text_input)) {
            # Process the text input from the textarea
            return(readBox(input$text_input)) # Assuming readBox is a custom function for text input
        }
        
        shiny::req(input$file_input)
        ext <- tools::file_ext(input$file_input$name)
        switch(ext,
               # txt = readGMT(input$file_input$datapath),
               txt = readLines(con = input$file_input$datapath),
               shiny::validate("Invalid file; Please upload a .txt file")
        )
    })
}