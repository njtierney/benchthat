#' Sets up overall benchmarking infrastructure
#'
#' Creates `benchmarks/benchthat/`, `benchmarks/benchthat.R`, and adds
#' the benchthat package to the Suggests field. Structure of code borrowed from
#' [usethis::use_test()].
#'
#' @seealso [use_bench()] to create individual benchmark files
#' @export
#' @examples
#' \dontrun{
#' use_benchthat()
#'
#' use_bench()
#'
#' use_bench("function-name")
#' }
use_benchthat <- function() {
  use_benchthat_impl()

  cli::cli_inform(
    message = c(
      "i" = "Call {.run benchthat::use_bench()} to initialize a basic benchmark
      file and open it for editing."
    )
  )
}

use_benchthat_impl <- function() {
  if (is_package()) {
    usethis::use_package(
      package = "benchthat",
      type = "Suggests"
    )
  }
  # else we don't mind, because you can use benchthat outside of a package
  # structure

  usethis::use_directory(fs::path("benchmarks", "benchthat"))
  usethis::use_template(
    "benchthat.R",
    save_as = fs::path("benchmarks", "benchthat.R"),
    data = list(name = usethis:::project_name())
  )
}

uses_benchthat <- function() {
  paths <- usethis::proj_path(
    c(fs::path("inst", "benchmarks"), fs::path("benchmarks", "benchthat"))
  )
  any(fs::dir_exists(paths))
}
