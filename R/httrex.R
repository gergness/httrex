#' Render a httrex
#'
#' @param x An expression. If not given, `httrex()` looks for code in
#'     `input` or on the clipboard, in that order.
#' @param input Character. If has length one and lacks a terminating newline,
#'     interpreted as the path to a file containing reprex code. Otherwise,
#'     assumed to hold reprex code as character vector.
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
    display = "details",
    data_out = TRUE,
    data_in = FALSE,
    info = FALSE,
    ssl = FALSE,
    hide_pkg_startup = TRUE,
    ...
) {
    input <- hijack_input(substitute(x), input, display, data_out, data_in, info, ssl, hide_pkg_startup)
    reprex::reprex(input = input, ...)
}

hijack_input <- function(x_expr, input, display, data_out, data_in, info, ssl, hide_pkg_startup) {
    where <- if (is.null(x_expr)) locate_input(input) else "expr"
    src <- switch(
        where,
        expr      = stringify_expression(x_expr),
        clipboard = ingest_clipboard(),
        path      = read_lines(input),
        input     = escape_newlines(sub("\n$", "", enc2utf8(input))),
        NULL
    )

    if (hide_pkg_startup) {
        library_override <- c(
            "library <- function(...) suppressPackageStartupMessages(base::library(...))",
            "require <- function(...) suppressPackageStartupMessages(base::require(...))"
        )
    } else {
        library_override <- NULL
    }

    verbose_call_string <- paste0(
        "httrex::hx_set_verbose(",
        "display = '", display, "', ",
        "data_out = ", data_out, ", ",
        "data_in = ", data_in, ", ",
        "info = ", info, ", ",
        "ssl = ", ssl,
        ")"
    )


    src <- c(
        "#+ include=FALSE",
        library_override,
        verbose_call_string,
        "#+",
        src
    )

    # TODO: re-writing it to disk seems like hack, but was easiest way to ensure
    # consistent formatting
    temp_file <- tempfile(fileext = ".txt")
    write_lines(src, temp_file)
    temp_file
}
