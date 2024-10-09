textInputBox <- function() {
    label_text_box <- stringr::str_c(
        "Enter list of NCBI taxids, taxon names, or metaphlan names:"
    )
    shiny::textAreaInput(
        inputId = "text_input",
        label = label_text_box,
        height = '200px',
        width = "500px", 
        placeholder = c("562\n561")
    )
}

fileInputBox <- function() {
    shiny::fileInput(
        inputId = "file_input",
        label = "Or upload a file:",
        accept = c(".txt"),
        buttonLabel = "Choose file..."
    )
}
