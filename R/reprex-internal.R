# nocov start

#!! copied from tidyverse/reprex
is_path <- function(x) {
    length(x) == 1 && is.character(x) && !grepl("\n$", x)
}

#!! copied from tidyverse/reprex
locate_input <- function(input) {
    if (is.null(input)) return("clipboard")
    if (is_path(input)) {
        "path"
    } else {
        "input"
    }
}

#!! copied from tidyverse/reprex
stringify_expression <- function(x) {
    if (is.null(x)) return(NULL)

    .srcref <- utils::getSrcref(x)

    if (is.null(.srcref)) {
        return(enc2utf8(deparse(x)))
    }

    ## Construct a new srcref with the first_line, first_byte, etc. from the
    ## first expression and the last_line, last_byte, etc. from the last one.
    first_src <- .srcref[[1]]
    last_src <- .srcref[[length(.srcref)]]

    .srcfile <- attr(first_src, "srcfile")

    src <- srcref(
        .srcfile,
        c(
            first_src[[1]], first_src[[2]],
            last_src[[3]], last_src[[4]],
            first_src[[5]], last_src[[6]],
            first_src[[7]], last_src[[8]]
        )
    )

    lines <- enc2utf8(as.character(src, useSource = TRUE))

    ## remove the first brace and line if the brace is the only thing on the line
    lines <- sub("^[{]", "", lines)
    if (!nzchar(lines[[1L]])) {
        lines <- lines[-1L]
    }

    ## identify the last source line affiliated with an expression
    n <- utils::getSrcLocation(last_src, which = "line", first = FALSE)

    ## rescue trailing comment on (current) last surviving line
    last_source_line <- getSrcLines(.srcfile, n, n) ## "raw"
    last_line <- lines[length(lines)] ## srcref'd
    m <- regexpr(last_line, last_source_line, fixed = TRUE)
    rescue_me <- substring(last_source_line, m + attr(m, "match.length"))
    if (grepl("^\\s*#", rescue_me)) {
        lines[length(lines)] <- paste0(last_line, rescue_me)
    }

    ## rescue trailing comment lines
    tail_lines <- getSrcLines(.srcfile, n + 1, Inf)
    closing_bracket_line <- max(grep("^\\s*[}]", tail_lines), 0)
    tail_lines <- utils::head(tail_lines, closing_bracket_line - 1)

    trim_common_leading_ws(c(lines, tail_lines))
}

#!! copied from tidyverse/reprex
clipboard_available <- function() {
    if (is_interactive()) {
        clipr::clipr_available()
    } else {
        isTRUE(as.logical(Sys.getenv("CLIPR_ALLOW", FALSE)))
    }
}

#!! copied from tidyverse/reprex
ingest_clipboard <- function() {
    if (clipboard_available()) {
        return(suppressWarnings(enc2utf8(clipr::read_clip())))
    }
    message("No input provided and clipboard is not available.")
    character()
}

#!! copied from tidyverse/reprex
readLines <- function(...) {
    stop("In this house, we use read_lines() for UTF-8 reasons.")
}

#!! copied from tidyverse/reprex
writeLines <- function(...) {
    stop("In this house, we use write_lines() for UTF-8 reasons.")
}

#!! copied from tidyverse/reprex
read_lines <- function(path, n = -1L) {
    if (is.null(path)) return(NULL)
    base::readLines(path, n = n, encoding = "UTF-8", warn = FALSE)
}

#!! copied from tidyverse/reprex
write_lines <- function(text, path, sep = "\n") {
    path <- file(path, open = "wb")
    on.exit(close(path), add = TRUE)
    base::writeLines(enc2utf8(text), con = path, sep = sep, useBytes = TRUE)
}

#!! copied from tidyverse/reprex
escape_newlines <- function(x) {
    gsub("\n", "\\\\n", x, perl = TRUE)
}

#!! copied from tidyverse/reprex
trim_common_leading_ws <- function(x) {
    m <- regexpr("^(\\s*)", x)
    n_chars <- nchar(x)
    n_spaces <- attr(m, which = "match.length")
    num <- min(n_spaces[n_chars > 0])
    substring(x, num + 1)
}

# nocov end
