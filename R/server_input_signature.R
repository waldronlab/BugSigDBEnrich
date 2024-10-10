readBox <- function(text_input) {
    char_vec <- unlist(strsplit(text_input, "\n"))
    char_vec <- char_vec[char_vec != ""]
}

inputSignature <- function(input) {
    shiny::reactive({
        cond1 <- !is.null(input$text_input) && nzchar(input$text_input)
        cond2 <- !is.null(input$file_input)
        if (isFALSE(cond1) & isFALSE(cond2)) {
            shiny::showNotification(
                "No input",
                type = "error"
            )
        }
        shiny::req(cond1 | cond2)
        if (cond1) {
            return(readBox(input$text_input))
        } else if (cond2) {
            ext <- tools::file_ext(input$file_input$name)
            return(switch(ext,
                txt = readLines(con = input$file_input$datapath),
                shiny::validate("Invalid file; Please upload a .txt file")
            ))
        }
    })
}
