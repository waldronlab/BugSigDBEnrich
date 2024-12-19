
#' Launch BugSigDBEnrich
#'
#' @return A shinyApp.
#' @export
#'
BugSigDBEnrich <- function() shiny::shinyApp(ui = createUI(), server = server)
