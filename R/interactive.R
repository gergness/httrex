#' Start/stop a httrex gadget
#'
#' A httrex gadget creates a shiny app that follows along your code and
#' tracks the httr calls that you make, providing details about your
#' interactions with a web API.
#'
#' @export
hx_gadget <- function() {
    start_tracing()
}

#' @export
#' @rdname hx_gadget
hx_gadget_stop <- function() {
    stop_tracing()
}

tracer_env <- new.env(parent = emptyenv())

start_tracing <- function(temp_dir = NULL) {
    tracer_env$active <- TRUE
    if (is.null(temp_dir)) temp_dir <- tempfile()
    tracer_env$shiny_dir <- temp_dir
    fs::dir_create(tracer_env$shiny_dir)

    start_saving_history()
    start_tracing_httr_verbs()


    app_file <- paste0(tracer_env$shiny_dir, "app.R")
    shiny_port <- servr::random_port()
    write_lines(
        paste0(
            "httrex:::st_app('", tracer_env$shiny_dir,
            "', port = ", shiny_port, ")"
        ),
        app_file
    )
    rstudioapi::jobRunScript(app_file, name = "httrex")
    Sys.sleep(1)
    message(
        paste0('Trying to open viewer with: rstudioapi::viewer(paste0("http://127.0.0.1:", ', shiny_port, '))')
    )
    rstudioapi::viewer(paste0("http://127.0.0.1:", shiny_port))
}

stop_tracing <- function() {
    tracer_env$active <- FALSE
    stop_tracing_httr_verbs()
}


# Save history ----

HX_DATE_FMT <- "%Y%m%d%H%M%S"
HX_LARGE_DATA_B <- 256 * 1012 # 256 kb

save_history <- function() {
    out_file_ts <- fs::path(
        tracer_env$shiny_dir,
        fs::path("history", format(Sys.time(), HX_DATE_FMT))
    )

    temp_file <- tempfile()
    last_ts <- tracer_env$timestamp

    utils::savehistory(temp_file)
    rhist <- readr::read_lines(temp_file)
    if (!is.null(last_ts)) {
        ts_pos <- which(rhist == last_ts[length(last_ts)])
        if (length(ts_pos) > 0) {
            ts_pos <- ts_pos[length(ts_pos)]
            if (ts_pos == length(rhist)) {
                rhist <- character(0)
            } else {
                rhist <- rhist[(ts_pos + 1):length(rhist)]
            }
        }
    }
    if (length(rhist) > 0) {
        write_lines(as.character(rhist), out_file_ts)
    }
    tracer_env$timestamp <- utils::timestamp(quiet = TRUE)
}

start_saving_history <- function() {
    tracer_env$timestamp <- utils::timestamp(quiet = TRUE)
    fs::dir_create(fs::path(tracer_env$shiny_dir, "history"))
    later_save_history(tracer_env$shiny_dir)
}

later_save_history <- function(temp_dir) {
    if (tracer_env$active) {
        save_history()
        later::later(later_save_history, delay = 3)
    }
}


# Trace httr verbs ----
HTTR_VERBS <- c("DELETE", "GET", "HEAD", "PATCH", "POST", "PUT", "VERB")
start_tracing_httr_verbs <- function() {
    tracer_env$verb_traced_count <- 0
    fs::dir_create(fs::path(tracer_env$shiny_dir, "trace_data"))
    purrr::walk(HTTR_VERBS, trace_httr_verb)
}

stop_tracing_httr_verbs <- function() {
    purrr::walk(HTTR_VERBS, ~suppressMessages(untrace(., where = asNamespace("httr"))))
}

trace_httr_verb <- function(f) {
    out <- suppressMessages(trace(
        f,
        where = asNamespace("httr"),
        exit = function() {
            tracer_env$verb_traced_count <- tracer_env$verb_traced_count + 1
            filename_count <- sprintf("%06d", tracer_env$verb_traced_count)
            raw_return <- returnValue()


            # Content - copy if already on disk, and save if big and in memory
            content <- raw_return$content
            if (inherits(content, "path")) {
                file_path <- fs::path(
                    tracer_env$shiny_dir,
                    "trace_data",
                    paste0(filename_count, "_", basename(content))
                )
                fs::file_copy(content, file_path)
                content <- structure(file_path, class = "path")
            } else if (utils::object.size(content) > HX_LARGE_DATA_B) {
                file_path <- fs::path(
                    tracer_env$shiny_dir,
                    "trace_data",
                    paste0(filename_count, "_content")
                )
                writeBin(content, file_path)
                content <- structure(file_path, class = "path")
            }

            out <- structure(list(
                method = raw_return$request$method,
                url = raw_return$request$url,
                status = raw_return$status_code,
                request_headers = raw_return$request$headers,
                request_fields = raw_return$request$fields,
                request_options = raw_return$request$options,
                cookies = raw_return$cookies,
                headers = raw_return$headers,
                content = raw_return$content,
                times = raw_return$times,
                trace_back = rlang::trace_back(),
                full = raw_return
            ), class = "response")

            file_name <- paste0(filename_count, ".Rds")
            saveRDS(out, fs::path(tracer_env$shiny_dir, "trace_data", file_name))
        },
        print = FALSE
    ))
}
