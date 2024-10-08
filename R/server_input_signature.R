inputSignature <- function(input) {
    shiny::reactive({
        # shiny::req(input$text_input)
        # readBox(input$text_input)
        # 
        
        shiny::req(input$file_input)
        ext <- tools::file_ext(input$file_input$name)
        switch(ext,
               gmt = readGMT(input$file_input$datapath),
               shiny::validate("Invalid file; Please upload a GMT file")
        )
    })
}