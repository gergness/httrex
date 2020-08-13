redact_msg <- function(type, msg) {
    gsub("\n(Authorization: Bearer)(.+?)\n", "\n\\1 ******\n", msg)
}

empty_function <- function(...) {
    # intentionally empty
}

prefix_message <- function(prefix, x, blank_line = FALSE) {
    lines <- unlist(strsplit(x, "\n", fixed = TRUE, useBytes = TRUE))

    out <- paste0(prefix, lines, collapse = "\n")

    if (blank_line)
        out <- paste0(out, "\n")
    out
}

format_msg <- function(type, msg) {
    type_string <- htypes(type)
    if (type_string %in% c("dataIn", "dataOut")) {
        json_msg <- try(jsonlite::prettify(msg), silent = TRUE)
        if (!inherits(json_msg, "try-error")) msg <- json_msg
    }

    switch(
        type_string,
        info = prefix_message("*  ", msg),
        headerIn = prefix_message("<- ", msg),
        headerOut = prefix_message("-> ", msg),
        dataIn = prefix_message("<<  ", msg, TRUE),
        dataOut = prefix_message(">> ", msg, TRUE),
        sslDataIn = prefix_message("*< ", msg, TRUE),
        sslDataOut = prefix_message("*> ", msg, TRUE)
    )
}

# inline -----
inline_format <- list(
    initialize = empty_function,
    redact_messages = redact_msg,
    format_messages = format_msg,
    accumulate_messages = function(msg) cat(paste0(msg, "\n")),
    finalize = function() cat("\n")
)

# details -----
details_initialize <- function() {
    details_initialize_set_hook()
    details_initialize_set_trace()
}

details_initialize_set_trace <- function() {
    suppressMessages(trace(
        curl::curl_fetch_memory,
        tracer = quote(httrex_debug_items <- list()),
        exit = function() {
            debug_items <- get("httrex_debug_items", envir = sys.frame(-1))
            output <- details_finalize_msgs(debug_items)
            if (!is.null(output)) {

                print(paste0(
                    "---HTTREX-ASIS-START---",
                    as.character(output),
                    "---HTTREX-ASIS-END---\n"
                ))
            }
        },
        print = FALSE
    ))
}

details_initialize_set_hook <- function() {
    old_chunk_hook <- knitr::knit_hooks$get("chunk")

    knitr::knit_hooks$set(chunk = function(x, options) {
        fence_char <- "`" # Make assumption
        fence <- paste(rep(fence_char, 3), collapse = "")

        output <- strsplit(x, "\n")[[1]]

        expand_lines <- which(grepl("---HTTREX-ASIS-START---.+---HTTREX-ASIS-END---", output))

        if (length(expand_lines) == 0) return(old_chunk_hook(x, options))

        output[expand_lines] <- gsub(".+---HTTREX-ASIS-START---(.+)---HTTREX-ASIS-END---.+", "\\1", output[expand_lines])
        output[expand_lines] <- gsub('\\\\"', '"', output[expand_lines])
        output <- unlist(lapply(seq_along(output), function(iii) {
            if (iii %in% expand_lines) c("```", "", unlist(strsplit(output[iii], "\\\\n")), "", "``` r") else output[iii]
        }))

        out <- old_chunk_hook(paste0(output, collapse = "\n"), options)

        out <- gsub(
            paste0("\n([", fence_char, "]{3,})( ", tolower(options$engine), ")?\n+\\1"),
            "",
            out
        )
        out
    })
}

details_accumulate_msg <- function(msg) {
    # TODO: This is terribly inefficient, but was the first way
    # I could figure out to assign things in the right environment
    debug_items <- get("httrex_debug_items", envir = sys.frame(-2))
    debug_items[[length(debug_items) + 1]] <- msg
    assign("httrex_debug_items", debug_items, envir = sys.frame(-2))
}

details_finalize_msgs <- function(msgs) {
    if (length(msgs) == 0) return(NULL)

    header_msgs <- grep("^->", msgs, value = TRUE)
    if (length(header_msgs) == 0) {
        summary_title <- "Request"
    } else {
        summary_title <- strsplit(header_msgs[1], "\n", fixed = TRUE)[[1]][1]
        summary_title <- gsub("^-> ", "", summary_title)
        summary_title <- htmltools::htmlEscape(summary_title)
    }

    paste(
        "<details style='margin-bottom:10px;margin-left:20px'>",
        "<summary>", summary_title, "</summary>",
        "<pre>",
        paste(msgs, collapse = "\n"),
        "</pre>",
        "</details>",
        sep = "\n"
    )
}

details_finalize <- function() {
    suppressMessages(untrace(curl::curl_fetch_memory))
}

details_format <- list(
    initialize = details_initialize,
    redact_messages = redact_msg,
    format_messages = format_msg,
    accumulate_messages = details_accumulate_msg,
    finalize = details_finalize
)
