
#' Launch my app
#'
#' @return A shinyApp
#' @export
#'
myApp <- function() shiny::shinyApp(ui = createUI(), server = server)
