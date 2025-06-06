#' Set up GitHub Actions workflows for branchmark
#'
#' @param overwrite Whether to overwrite existing workflow files
#' @export
use_branchmark_github <- function(overwrite = FALSE) {
  # Create .github/workflows directory
  workflows_dir <- fs::path(".github", "workflows")
  fs::dir_create(workflows_dir, recurse = TRUE)

  # Copy workflow templates
  copy_workflow_template("branchmark-pr.yml", workflows_dir, overwrite)
  copy_workflow_template("branchmark-baseline.yml", workflows_dir, overwrite)

  cli::cli_alert_success("GitHub Actions workflows created")
  cli::cli_alert_info(
    "Configure repository permissions for Actions to write pull request comments"
  )

  invisible(TRUE)
}

#' Set up GitHub workflows with custom configuration
#'
#' @param runner_os Operating system for GitHub runners ("ubuntu-latest", "macos-latest", "windows-latest")
#' @param r_version R version to use in workflows
#' @export
setup_workflows <- function(
  runner_os = "ubuntu-latest",
  r_version = "release"
) {
  # Implementation for customised workflow setup
  config <- list(
    runner_os = runner_os,
    r_version = r_version
  )

  # Generate customised workflows
  generate_custom_workflows(config)
}

#' Copy workflow template to destination
#' @keywords internal
copy_workflow_template <- function(template_name, dest_dir, overwrite) {
  template_path <- system.file(
    "templates",
    template_name,
    package = "branchmark"
  )
  dest_path <- fs::path(dest_dir, template_name)

  if (fs::file_exists(dest_path) && !overwrite) {
    cli::cli_alert_info(
      "Workflow {.path {template_name}} already exists. Use {.code overwrite = TRUE} to replace."
    )
    return(invisible(FALSE))
  }

  fs::file_copy(template_path, dest_path, overwrite = overwrite)
  cli::cli_alert_success("Created workflow {.path {template_name}}")

  invisible(TRUE)
}
