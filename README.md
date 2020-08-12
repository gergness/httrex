# httrex

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/httrex)](https://CRAN.R-project.org/package=httrex)
<!-- badges: end -->

The httrex package aims to help developers of R API clients create more
“reprex”-like example code that describes both the R code that was run
and the API calls their code is making.

## Installation

httrex is not (yet) on CRAN, install using the `remotes` package.

``` r
remotes::install_github("gergness/httrex")
```

## Example

The `covid19us` package wraps the COVID Tracking Project API
<https://covidtracking.com/api/>, and is a nice way to test run `httrex`
because it does not require any authentication.

``` r
httrex::httrex({
    library(covid19us)
    get_us_current()
})

#> Rendering reprex...
#> Rendered reprex is on the clipboard.
```

Which displays the following in your Viewer (if using RStudio) and
puts the content on your clipboard (if available).  
<a href="man/figures/ex1.md">Markdown Code</a>

<a href="man/figures/ex1.md"><img src="man/figures/ex1.gif"/></a>


You can also get the data received by the http requests by using the
option `data_in = TRUE`.

``` r
httrex::httrex({
    library(covid19us)
    get_us_current()
}, display = "details", data_in = TRUE)

#> Rendering reprex...
#> Rendered reprex is on the clipboard.
```

Which displays the following in your Viewer (if using RStudio) and
puts the content on your clipboard (if available).  
<a href="man/figures/ex2.md">Markdown Code</a>

<a href="man/figures/ex2.md"><img src="man/figures/ex2.gif"/></a>




Like the `reprex` package, `httrex` will try to read off your clipboard
if you leave the `x` and `input` arguments empty.
