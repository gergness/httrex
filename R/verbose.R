#' Start/Stop verbose output
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
#' @param display Either "inline" to indicate that the verbose output
#'   should be printed as inline comments or "details" which uses HTML
#'   tags to make expandable tags. `NULL` the default chooses `details`
#'   when working in a knitr context and `inline` otherwise.
#' @param data_out Show data sent to server
#' @param data_in Show data received from server
#' @param info Show informational text from curl. This is mainly useful for debugging
#'     https and auth problems, so is disabled by default
#' @param ssl Show even data sent/recieved over SSL connections?
#'
#' @export
hx_set_verbose <- function(
    display = NULL,
    data_out = TRUE,
    data_in = FALSE,
    info = FALSE,
    ssl = FALSE
) {
    if (is.null(display)) {
        display <- ifelse(
            isTRUE(getOption('knitr.in.progress')),
            "details",
            "inline"
        )
    }

    formatting <- switch(
        display,
        "inline" = inline_format,
        "details" = details_format,
        stop(paste0(
            "`display` must be either 'inline' or 'details', but was '", display, "'"
        ))
    )

    formatting$initialize()

    httr::set_config(hx_verbose(formatting, data_out, data_in, info, ssl))
    options(httrex_finalize = formatting$finalize)
}

#' @rdname hx_set_verbose
#' @export
hx_stop_verbose <- function() {
    httr::set_config(debugfunction = NULL, verbose = FALSE)
    options("httrex_finalize")()
    options(httrex_finalize = NULL)
}

hx_verbose <- function (
    formatting,
    data_out = TRUE,
    data_in = FALSE,
    info = FALSE,
    ssl = FALSE
) {
    httr::config(
        debugfunction = httrex_new_debug(formatting, data_out, data_in, info, ssl),
        verbose = TRUE
    )
}


httrex_new_debug <- function(
    formatting,
    data_out = TRUE,
    data_in = FALSE,
    info = FALSE,
    ssl = FALSE
) {

    function(type, msg) {
        if ((knitr::opts_current$get("label") %||% "") == "setup") return()

        data_out <- knitr::opts_current$get("hx.data_out") %||% data_out
        data_in <- knitr::opts_current$get("hx.data_in") %||% data_in
        info <- knitr::opts_current$get("hx.info") %||% info
        ssl <- knitr::opts_current$get("hx.ssl") %||% ssl

        type_string <- htypes(type)
        if (type_string == "info" && !info) return()
        if (type_string == "dataIn" && !data_in) return()
        if (type_string == "dataOut" && !data_out) return()
        if (type_string == "sslDataIn" && (!ssl || !data_in)) return()
        if (type_string == "sslDataOut" && (!ssl || !data_out)) return()

        if (type_string %in% c("dataIn")) {
            suppressWarnings(msg <- memDecompress(msg))
        }

        msg <- readBin(msg, character())
        msg <- gsub("\\r?\\n\\r?", "\n", msg) # standardize new line format to \n

        msg <- formatting$redact_messages(type, msg)
        msg <- formatting$format_messages(type, msg)
        formatting$accumulate_messages(msg)
    }
}
