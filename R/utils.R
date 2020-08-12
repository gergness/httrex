`%||%` <- function(a, b) {
    if (is.null(a)) b else a
}

htypes <- function(iii) {
    list(
        "info",
        "headerIn",
        "headerOut",
        "dataIn",
        "dataOut",
        "sslDataIn",
        "sslDataOut"
    )[[iii + 1]]
}
