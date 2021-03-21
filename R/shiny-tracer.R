

st_app <- function(dir, port = NULL) {
    find_new_history <- find_new_history_func(fs::path(dir, "history"))
    find_new_verbs <- find_new_httr_verbs_func(fs::path(dir, "trace_data"))

    app <- shiny::shinyApp(
        ui = shiny::bootstrapPage(
            title = "httrex tracer",
            theme = bslib::bs_theme(version = "4", bootswatch = "sandstone"),
            shiny::tags$body(
                includeHighlightJs(),
                style = "padding-top:80px",
                st_heading(),
                tags$div(
                    class = "px-2",
                    st_new_row(
                        "1",
                        code_content = shiny::uiOutput("code1", container = rCodeContainer),
                        annotation_content = shiny::uiOutput("ann1", container = tags$span)
                    )
                )

            )
        ),
        server = function(input, output, session) {
            auto_invalidate <- shiny::reactiveTimer(2 * 1000)
            code_text <- shiny::reactiveVal(character(0))
            trace_html <- shiny::reactiveVal(list())

            shiny::observeEvent(auto_invalidate(), {
                old_code_text <- code_text()
                code_text(c(old_code_text, find_new_history()))


                old_trace_html <- trace_html()
                trace_html(c(old_trace_html, find_new_verbs()))
            })



            output$code1 <- renderCode({
                out <- paste(
                    sep = "\n",
                    code_text()
                )
                highlightCode(session, "code1")
                out
            })

            output$ann1 <- shiny::renderUI({
                shiny::tagList(
                    trace_html()
                )
            })
        }
    )

    shiny::runApp(app, port = port)
}


# --- UI Components ----

#' @importFrom htmltools tags
st_heading <- function() {
    tags$nav(
        class = "navbar navbar-expand-sm fixed-top navbar-dark bg-primary",
        tags$a("httrex tracer", class = "navbar-brand"),
        tags$button(
            class = "navbar-toggler",
            type = "button",
            `data-toggle` = "navbar",
            tags$span(class="navbar-toggler-icon")
        ),
        tags$div(
            class = "collapse navbar-collapse",
            id = "navbar",
            tags$ul(
                class = "navbar-nav mr-auto",
                tags$li(
                    class = "nav-item active",
                    tags$a(class = "nav-link", href = "#", "Home")
                )
            )
        )
    )
}

st_new_row <- function(id, code_content, annotation_content) {
    tags$div(
        class = "px-2",
        tags$div(
            class = "row",
            id = paste0("row-", id),
            tags$div(
                class = "col-lg-5",
                code_content
            ),
            tags$div(
                class = "col-lg-7 align-self-end",
                id = paste0("annotation-", id),
                annotation_content
            )
        )
    )
}

# Goal:
# - header: button to pause updating (with badge of how many commands missed)
#           expand/collapse all buttons
# - Two column view (when on large(medium?) and larger sizes)
# - left hand column: code (highlighted by highlight.js)
#   only broken into when there are things in the right hand column
# - right hand column: expandable divs
#   Always visible part: VERB + URL RETURN STATUS # (with color)
#   Tabbed view: (Request headers, body, response headers, response)



# ---- Parsing history files ----
find_new_history_func <- function(path) {
    last_timestamp <- NULL

    function() {
        files <- fs::dir_ls(path)
        file_timestamps <- lubridate::parse_date_time(basename(files), HX_DATE_FMT)
        if (!is.null(last_timestamp)) {
            files <- files[!is.na(file_timestamps) & file_timestamps > last_timestamp]
        }
        out <- purrr::map(files, parse_history_file)
        out <- purrr::flatten_chr(out)

        if (length(file_timestamps) > 0) {
            last_timestamp <<- max(file_timestamps)
        }
        out
    }
}

parse_history_file <- function(file) {
    hist <- readr::read_file(file)
    out <- tryCatch({
        parsed <- rlang::parse_exprs(hist)
        purrr::map_chr(parsed, ~htmltools::htmlEscape(styler::style_text(deparse(.))))
    }, error = function(e) hist)
}


# ---- Code highlighting (adapted from rstudio/addinexamples::utils.R ----
injectHighlightHandler <- function() {
    code <- "
    Shiny.addCustomMessageHandler('highlight-code', function(message) {
        var id = message['id'];
        setTimeout(function() {
            var el = document.getElementById(id);
            hljs.highlightBlock(el);
        }, 100);
    });
    "

    tags$script(code)
}

includeHighlightJs <- function() {
    resources <- system.file("www/shared/highlight", package = "shiny")
    list(
        shiny::includeScript(file.path(resources, "highlight.pack.js")),
        shiny::includeCSS(file.path(resources, "rstudio.css")),
        injectHighlightHandler()
    )
}

highlightCode <- function(session, id) {
    session$sendCustomMessage("highlight-code", list(id = id))
}

renderCode <- function(expr, env = parent.frame(), quoted = FALSE) {
    func <- NULL
    shiny::installExprFunction(expr, "func", env, quoted)
    shiny::markRenderFunction(shiny::textOutput, function() {
        paste(func(), collapse = "\n")
    })
}

rCodeContainer <- function(...) {
    code <- htmltools::HTML(as.character(tags$code(class = "language-r", ...)))
    tags$div(tags$pre(code))
}



# ---- httr verb viewer ----
find_new_httr_verbs_func <- function(path) {
    last_id <- NULL

    function() {
        files <- fs::dir_ls(path)
        file_ids <- as.numeric(stringr::str_extract(files, "[0-9]+(?=\\.Rds)"))
        if (!is.null(last_id)) {
            files <- files[!is.na(file_ids) & file_ids > last_id]
        }
        out <- purrr::imap(unname(files), ~httr_verb_viewer(paste0("vv", .y), .x))

        if (length(file_ids) > 0) {
            last_id <<- max(file_ids)
        }

        out
    }
}


httr_verb_viewer <- function(id, file) {
    x <- readRDS(file)
    out <- tryCatch({
        tags$div(
            class = "card",
            tags$p(
                tags$strong(x$method),
                status_info(x$status),
                x$url
            ),
            shiny::tabsetPanel(
                id = paste0(id, "-tabset"),
                shiny::tabPanel("Summary", httr_verb_summary(x)),
                shiny::tabPanel("Request", httr_verb_request(x)),
                shiny::tabPanel("Response", httr_verb_response(x)),
                shiny::tabPanel("Response Body", httr_verb_response_body(x)),
                shiny::tabPanel("Traceback", httr_verb_trace(x))
            )
        )},
        error = function(e) {
            tags$p(class = "danger-text", "Could not load: ", as.character(e))
        }
    )
    out
}

httr_verb_summary <- function(x) {
    content_type <- x$headers$`content-type`
    if (is.null(content_type)) content_type <- "<unknown>"
    if (inherits(x$content, "path")) {
        content_size <- file.info(x)$size
    } else {
        content_size <- length(x$content)
    }

    detail_list(list(
        "Content type" = content_type,
        "Size" = bytes(content_size)
    ))
}

httr_verb_request <- function(x) {
    if ("postfields" %in% names(x$request_options)) {
        postfield <- rawToChar(x$request_options$postfields)
        if (jsonlite::validate(postfield)) {
            body <- shiny::tagList(
                tags$h4("Request Body"),
                listviewer::jsonedit(postfield, width = "100%")
            )
        } else {
            body <- shiny::tagList(
                tags$h4("Request Body"),
                tags$pre(tags$code(htmltools::htmlEscape(postfield)))
            )
        }
        x$request_options$postfields <- NULL
    } else {
        body <- NULL
    }


    shiny::tagList(
        tags$h4("Headers"),
        detail_list(x$request_headers),
        tags$h4("Options"),
        detail_list(x$request_options),
        body
    )
}


httr_verb_response <- function(x) {
    shiny::tagList(
        tags$h4("Headers"),
        detail_list(x$headers),
        tags$h4("Cookies"),
        # TODO: a table
        tags$p("TKTKTK")
    )
}

httr_verb_response_body <- function(x) {
    text <- httr::content(x, as = "text")
    if (jsonlite::validate(text)) {
        shiny::tagList(
            listviewer::jsonedit(text, width = "100%")
        )
    } else {
        if (nchar(text) > 1000) {
            text <- stringr::str_trunc(text, 1000)
        }
        tags$pre(tags$code(text))
    }
}

httr_verb_trace <- function(x) {
    text <- cli::ansi_strip(utils::capture.output(summary(x$trace_back)))
    tags$pre(
        paste(text, collapse = "\n")
    )
}

status_info <- function(code) {
    info <- try(httr::http_status(code))
    if (inherits(info, "try-error")) {
        tags$span(code, class = "badge badge-secondary")
    } else if (info$category == "Success") {
        tags$span(code, class = "badge badge-success")
    } else if (info$category %in%  c("Client error", "Server error")) {
        tags$span(code, class = "badge badge-danger")
    } else {
        tags$span(code, class = "badge badge-secondary")
    }
}

bytes <- function (x, digits = 3, ...) {
    power <- min(floor(log(abs(x), 1000)), 4)
    if (power < 1) {
        unit <- "B"
    }
    else {
        unit <- c("kB", "MB", "GB", "TB")[[power]]
        x <- x/(1000^power)
    }
    formatted <- format(signif(x, digits = digits), big.mark = ",",
                        scientific = FALSE)
    paste0(formatted, " ", unit)
}


# ---- html helpers ----
str_if_not_single <- function(x) {
    if (length(x) > 1) {
        utils::capture.output(utils::str(x, max.level = 4, nchar.max=1000))
    } else {
        x
    }
}

detail_list <- function(x) {
    items <- purrr::imap(
        x,
        ~list(
            tags$dt(.y, class = "col-sm-3"),
            tags$dl(str_if_not_single(.x), class = "col-sm-9")
        )
    )
    do.call(function(...) tags$dl(class = "px-2 row", ...), unname(items))
}

# ---- Scrap ----
st_accordion <- function() {
    tags$div(
        class = "accordion",
        id = "accordionExample",
        tags$div(
            class = "card",
            tags$div(
                class = "card-header",
                id = "headingOne",
                tags$h5(
                    class = "mb-0",
                    tags$button(
                        class = "btn btn-link",
                        type = "button",
                        `data-toggle` = "collapse",
                        `data-target` = "#collapseOne",
                        `aria-expanded` = "true",
                        `aria-controls` = "collapseOne",
                        "Item #1",
                    )
                )
            ),
            tags$div(
                id = "collapseOne",
                class = "collapse show",
                `aria-labelledby` = "headingOne",
                `data-parent` = "#accordionExample",
                tags$div(class = "card-body", "Hello!")
            )
        ),
        tags$div(
            class = "card",
            tags$div(
                class = "card-header",
                id = "headingTwo",
                tags$h5(
                    class = "mb-0",
                    tags$button(
                        class = "btn btn-link collapsed",
                        type = "button",
                        `data-toggle` = "collapse",
                        `data-target` = "#collapseTwo",
                        `aria-expanded` = "true",
                        `aria-controls` = "collapseTwo",
                        "Item #2",
                    )
                )
            ),
            tags$div(
                id = "collapseTwo",
                class = "collapse",
                `aria-labelledby` = "headingTwo",
                `data-parent` = "#accordionExample",
                tags$div(class = "card-body", "Hello again!")
            )
        )
    )
}

