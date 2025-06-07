# taken from https://github.com/r-lib/usethis/blob/4aa55e72ccca131df2d98fcd84fff66724d6250a/R/proj.R#L206

is_package <- function(base_path = proj_get()) {
  res <- tryCatch(
    rprojroot::find_package_root_file(path = base_path),
    error = function(e) NULL
  )
  !is.null(res)
}

rstudio_available <- function() {
  rstudioapi::isAvailable()
}

# taken from https://github.com/r-lib/usethis/blob/4aa55e72ccca131df2d98fcd84fff66724d6250a/R/r.R#L142

compute_name <- function(
  name = NULL,
  ext = "R",
  error_call = rlang::caller_env()
) {
  if (!is.null(name)) {
    check_file_name(name, call = error_call)

    if (fs::path_ext(name) == "") {
      name <- fs::path_ext_set(name, ext)
    } else if (fs::path_ext(name) != ext) {
      cli::cli_abort(
        "{.arg name} must have extension {.str {ext}}, not {.str {path_ext(name)}}.",
        call = error_call
      )
    }
    return(as.character(name))
  }

  if (!rstudio_available()) {
    cli::cli_abort(
      "{.arg name} is absent but must be specified.",
      call = error_call
    )
  }
  compute_active_name(
    path = rstudioapi::getSourceEditorContext()$path,
    ext = ext,
    error_call = error_call
  )
}

compute_active_name <- function(path, ext, error_call = rlang::caller_env()) {
  if (is.null(path)) {
    cli::cli_abort(
      c(
        "No file is open in RStudio.",
        i = "Please specify {.arg name}."
      ),
      call = error_call
    )
  }

  ## rstudioapi can return a path like '~/path/to/file' where '~' means
  ## R's notion of user's home directory
  path <- usethis:::proj_path_prep(fs::path_expand_r(path))

  dir <- fs::path_dir(usethis:::proj_rel_path(path))
  if (
    !dir %in%
      c("R", "src", "benchmarks/benchthat", "benchmarks/benchthat/_bench")
  ) {
    cli::cli_abort(
      "Open file must be code, test, or snapshot.",
      call = error_call
    )
  }

  file <- fs::path_file(path)
  if (dir == "benchmarks/benchthat") {
    file <- gsub("^bench[-_]", "", file)
  }
  as.character(fs::path_ext_set(file, ext))
}

check_file_name <- function(name, call = rlang::caller_env()) {
  if (!is_string(name)) {
    cli::cli_abort("{.arg name} must be a single string", call = call)
  }

  if (name == "") {
    cli::cli_abort("{.arg name} must not be an empty string", call = call)
  }

  if (fs::path_dir(name) != ".") {
    cli::cli_abort(
      "{.arg name} must be a file name without directory.",
      call = call
    )
  }

  if (!usethis:::valid_file_name(fs::path_ext_remove(name))) {
    cli::cli_abort(
      c(
        "{.arg name} ({.str {name}}) must be a valid file name.",
        i = "A valid file name consists of only ASCII letters, numbers, '-', and '_'."
      ),
      call = call
    )
  }
}
