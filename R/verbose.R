#' Give verbose output
#'
#' A verbose connection provides much more information about the flow of
#' information between the client and server. `hx_verbose()` differs
#' from [`httr::verbose()`] because it prints during `httrex` / `reprex`
#' rendering.
#'
#' @section Overriding during `httrex` rendering:
#' `httrex` allows for overriding options per knitr chunk using chunk options.
#' During a `httrex()` call the knitr options can be set by starting a line with
#' `#+` and then setting the options to R values.
#'
#' The available options are:
#'  * If the chunk label is "setup", no verbose output is provided. This allows
#'    sensitive details to be kept confidential, such as a password when logging in.
#'  * `hx.data_in`, `hx.data_out`, `hx.info`, `hx.ssl` override the arguments to
#'  `verbose()`.
#'
#'  Example code that could be sent to `httrex()`:
#'  ```
#'  #+ setup                # makes a chunk with label "setup" so there's no verbose output
#'  library(crunch)
#'  login()
#'  #+                      # Nothing after `#+` returns to defaults
#'  listDatasets()
#'  #+ hx.data_out=TRUE     # Override so that `data_out` is printed
#'  ```
#'
#' @section Prefixes:
#'
#' `verbose()` uses the following prefixes to distinguish between
#' different components of the http messages:
#'
#' * `*` informative curl messages
#' * `->` headers sent (out)
#' * `>>` data sent (out)
#' * `*>` ssl data sent (out)
#' * `<-` headers received (in)
#' * `<<` data received (in)
#' * `<*` ssl data received (in)
#'
#' @param data_out Show data sent to server
#' @param data_in Show data received from server
#' @param info Show informational text from curl. This is mainly useful for debugging
#'     https and auth problems, so is disabled by default
#' @param ssl Show even data sent/recieved over SSL connections?
#' @param expr An expression to be evaluated with verbose settings
#' @param ... passed to `hx_verbose()`
#'
#' @return An `httr::config` object
#' @export
hx_verbose <- function (data_out = TRUE, data_in = FALSE, info = FALSE, ssl = FALSE) {
    debug <- function(type, msg) {
        if ((knitr::opts_current$get("label") %||% "") == "setup") return()

        data_out <- knitr::opts_current$get("hx.data_out") %||% data_out
        data_in <- knitr::opts_current$get("hx.data_in") %||% data_in
        info <- knitr::opts_current$get("hx.info") %||% info
        ssl <- knitr::opts_current$get("hx.ssl") %||% ssl

        switch(
            type + 1,
            text = if (info) prefix_message("*  ", msg),
            headerIn = prefix_message("<- ", msg),
            headerOut = prefix_message("-> ", msg),
            dataIn = if (data_in) prefix_message("<<  ", memDecompress(msg), TRUE),
            dataOut = if (data_out) prefix_message(">> ", msg, TRUE),
            sslDataIn = if (ssl && data_in) prefix_message("*< ", msg, TRUE),
            sslDataOut = if (ssl && data_out) prefix_message("*> ", msg, TRUE)
        )
    }
    httr::config(debugfunction = debug, verbose = TRUE)
}

#' @rdname hx_verbose
#' @export
with_hx_verbose <- function(expr, ...) {
    httr::with_config(hx_verbose(...), expr)
}


# adapted from httr
prefix_message <- function(prefix, x, blank_line = FALSE) {
    x <- readBin(x, character())
    lines <- unlist(strsplit(x, "\n", fixed = TRUE, useBytes = TRUE))
    out <- paste0(prefix, lines, collapse = "\n")
    cat(paste0(out, "\n"))
    if (blank_line)
        cat("\n")
}
