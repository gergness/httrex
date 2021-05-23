#' Render a httrex
#'
#' @param x An expression. If not given, `httrex()` looks for code in
#'     `input` or on the clipboard, in that order.
#' @param input Character. If has length one and lacks a terminating newline,
#'     interpreted as the path to a file containing reprex code. Otherwise,
#'     assumed to hold reprex code as character vector.
#' @param wd The working directory to run the httrex example in. Note that httrex
#' must set the `wd` itself, but if you pass a `wd` it will move to your working
#' directory after it's own setup.
#' @inheritParams hx_set_verbose
#' @param hide_pkg_startup Whether to override `library()` and `require()` calls
#'   with ones that suppress the package startup messages (Defaults to `TRUE`).
#' @param ... Other options passed to [`reprex::reprex()`]
#' @export
#'
#' @import rlang
#' @import fs
httrex <- function(
    x = NULL,
    input = NULL,
    wd = NULL,
    data_out = TRUE,
    data_in = TRUE,
    info = FALSE,
    ssl = FALSE,
    hide_pkg_startup = TRUE,
    ...
) {
    temp_wd <- prepare_temp_wd(wd, data_out, data_in, info, ssl, hide_pkg_startup)
    on.exit(copy_reprex_files(wd, temp_wd), add = TRUE)
    # Use awkward do.call syntax because of NSE (maybe rlib would work better here?)
    do.call(reprex::reprex, list(x = substitute(x), input = input, wd = temp_wd, ...))
}

# Make a temporary working directory to inject httrex code but also try to respect user's working
# directory if they specified one
prepare_temp_wd <- function(wd, data_out, data_in, info, ssl, hide_pkg_startup) {
    temp_dir <- make_temp_dir()
    make_rprofile(temp_dir, wd, data_out, data_in, info, ssl, hide_pkg_startup)
    copy_renviron(temp_dir, wd)

    temp_dir
}

make_temp_dir <- function() {
    temp_dir <- tempfile()
    fs::dir_create(temp_dir)
    temp_dir
}

make_rprofile <- function(temp_dir, wd, data_out, data_in, info, ssl, hide_pkg_startup) {
    rprofile <- sprintf(
        "httrex:::prepare_reprex(data_out = %s, data_in = %s,info = %s, ssl = %s)",
        data_out, data_in, info, ssl
    )

    if (hide_pkg_startup) {
        rprofile <- c(
            rprofile,
            "library <- function(...) suppressPackageStartupMessages(base::library(...))",
            "require <- function(...) suppressPackageStartupMessages(base::require(...))"
        )
    }

    if (!is.null(wd) && fs::file_exists(fs::path(wd, ".Rprofile"))) {
        rprofile <- c(
            rprofile,
            paste0("setwd('", wd, "')"),
            "source('.Rprofile')"
        )
    }

    writeLines(rprofile, fs::path(temp_dir, ".Rprofile"))
}

copy_renviron <- function(temp_dir, wd) {
    old_env <- fs::path(wd, ".Renviron")
    if (!is.null(wd) && fs::file_exists(old_env)) {
        fs::file_copy(old_env, fs::path(temp_dir, ".Renviron"))
    }
}

prepare_reprex <- function(data_out, data_in, info, ssl) {
    httrex::hx_set_verbose(
        data_out = data_out,
        data_in = data_in,
        info = info,
        ssl = ssl
    )
}

copy_reprex_files <- function(wd, temp_wd) {
    if (is.null(wd)) return()

    # Don't copy .Renviron or .Rprofile because we don't want to overwrite
    # the user's original files
    files <- fs::dir_ls(
        temp_wd,
        recurse = TRUE,
        regexp = "\\.Renviron$|\\.Rprofile",
        invert = TRUE
    )

    fs::file_copy(files, wd)
}
