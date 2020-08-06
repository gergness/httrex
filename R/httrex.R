#' Render a httrex
#'
#' @param x An expression. If not given, `httrex()` looks for code in
#'     `input` or on the clipboard, in that order.
#' @param input Character. If has length one and lacks a terminating newline,
#'     interpreted as the path to a file containing reprex code. Otherwise,
#'     assumed to hold reprex code as character vector.
#' @param ... Other options passed to [`reprex::reprex()`]
#' @export
#'
#' @import rlang
#' @import fs
httrex <- function(
    x = NULL,
    input = NULL,
    ...
) {
    input <- hijack_input(substitute(x), input)
    reprex::reprex(input = input, ...)
}

hijack_input <- function(x_expr, input) {
    where <- if (is.null(x_expr)) locate_input(input) else "expr"
    src <- switch(
        where,
        expr      = stringify_expression(x_expr),
        clipboard = ingest_clipboard(),
        path      = read_lines(input),
        input     = escape_newlines(sub("\n$", "", enc2utf8(input))),
        NULL
    )

    src <- c(
        "#+ include=FALSE",
        "httr::set_config(httrex::hx_verbose())",
        "#+",
        src
    )

    # TODO: re-writing it to disk seems like hack, but was easiest way to ensure
    # consistent formatting
    temp_file <- tempfile(fileext = ".txt")
    write_lines(src, temp_file)
    temp_file
}
