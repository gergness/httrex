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

# Originally tried to support other formatting (eg "details")
# but decided that it wasn't worth it
# inline -----
inline_format <- list(
    initialize = empty_function,
    redact_messages = redact_msg,
    format_messages = format_msg,
    accumulate_messages = function(msg) cat(paste0(msg, "\n")),
    finalize = function() {}
)
