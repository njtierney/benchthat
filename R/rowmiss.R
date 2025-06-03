#' Calculate ross missing
#'
#' @param data data frame
#'
#' @returns number of missing values
#' @export
#'
#' @examples
#' rowmiss(airquality)
rowmiss <- function(data) {
  apply(data, 1, function(row) sum(is.na(row)))
}
