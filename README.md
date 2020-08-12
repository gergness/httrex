
<!-- README.md is generated from README.Rmd. Please edit that file -->

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

Which puts the following on your clipboard:

-----

``` r
library(covid19us)
get_us_current()
```

<details style="margin-bottom:10px;margin-left:20px">

<summary> -> GET /api/v1/us.json HTTP/2 </summary>

<pre>
-> GET /api/v1/us.json HTTP/2
-> Host: covidtracking.com
-> User-Agent: libcurl/7.64.1 r-curl/4.3 httr/1.4.2
-> Accept-Encoding: deflate, gzip
-> Accept: application/json, text/xml, application/xml, */*
-> 
<- HTTP/2 200 
<- accept-ranges: bytes
<- access-control-allow-origin: *
<- age: 93
<- cache-control: max-age=600
<- content-encoding: gzip
<- content-length: 341
<- content-type: application/json; charset=utf-8
<- date: Wed, 12 Aug 2020 18:24:49 GMT
<- etag: W/"5f343337-278"
<- expires: Wed, 12 Aug 2020 18:32:39 GMT
<- last-modified: Wed, 12 Aug 2020 18:21:43 GMT
<- server: Netlify
<- strict-transport-security: max-age=31556952
<- via: 1.1 varnish
<- x-cache: HIT
<- x-cache-hits: 2
<- x-fastly-request-id: 0c0c98c2a6d6fb04d340a260479c51aa8d1b5b91
<- x-github-request-id: 232A:7DD7:E1E1D:11720B:5F34336E
<- x-origin-cache: HIT
<- x-proxy-cache: MISS
<- x-served-by: cache-ewr18130-EWR
<- x-timer: S1597256689.018486,VS0,VE0
<- vary: Accept-Encoding
<- x-nf-request-id: 5d0f37c9-4918-43f5-b7ef-54e377ba49a8-2746440
<- 
</pre>

</details>

``` r
#> # A tibble: 1 x 25
#>   date       states positive negative pending hospitalized_cu… hospitalized_cu…
#>   <date>      <int>    <int>    <int>   <int>            <int>            <int>
#> 1 2020-08-11     56  5116474 58135783    4118            48500           337062
#> # … with 18 more variables: in_icu_currently <int>, in_icu_cumulative <int>,
#> #   on_ventilator_currently <int>, on_ventilator_cumulative <int>,
#> #   recovered <int>, date_checked <dttm>, death <int>, hospitalized <int>,
#> #   last_modified <chr>, total <int>, total_test_results <int>,
#> #   death_increase <int>, hospitalized_increase <int>, negative_increase <int>,
#> #   positive_increase <int>, total_test_results_increase <int>, hash <chr>,
#> #   request_datetime <dttm>
```

<sup>Created on 2020-08-12 by the [reprex
package](https://reprex.tidyverse.org) (v0.3.0.9001)</sup>

-----

You can also get the data received by the http requests by using the
option `data_in = TRUE`.

``` r
httrex::httrex({
    library(covid19us)
    get_us_current()
}, display = "details", data_in = TRUE)
```

Which puts the following on your clipboard:

-----

``` r
library(covid19us)
get_us_current()
```

<details style="margin-bottom:10px;margin-left:20px">

<summary> -> GET /api/v1/us.json HTTP/2 </summary>

<pre>
-> GET /api/v1/us.json HTTP/2
-> Host: covidtracking.com
-> User-Agent: libcurl/7.64.1 r-curl/4.3 httr/1.4.2
-> Accept-Encoding: deflate, gzip
-> Accept: application/json, text/xml, application/xml, */*
-> 
<- HTTP/2 200 
<- accept-ranges: bytes
<- access-control-allow-origin: *
<- age: 482
<- cache-control: max-age=600
<- content-encoding: gzip
<- content-length: 341
<- content-type: application/json; charset=utf-8
<- date: Wed, 12 Aug 2020 18:31:16 GMT
<- etag: W/"5f343337-278"
<- expires: Wed, 12 Aug 2020 18:32:39 GMT
<- last-modified: Wed, 12 Aug 2020 18:21:43 GMT
<- server: Netlify
<- strict-transport-security: max-age=31556952
<- via: 1.1 varnish
<- x-cache: HIT
<- x-cache-hits: 3
<- x-fastly-request-id: bf24babe8c28f8695c159d71d5f720ca57b12864
<- x-github-request-id: 232A:7DD7:E1E1D:11720B:5F34336E
<- x-origin-cache: HIT
<- x-proxy-cache: MISS
<- x-served-by: cache-ewr18125-EWR
<- x-timer: S1597257077.907034,VS0,VE0
<- vary: Accept-Encoding
<- x-nf-request-id: 474110da-aa2c-4e52-b2c4-32c128ba3043-652759
<- 
<<  [
<<      {
<<          "date": 20200811,
<<          "states": 56,
<<          "positive": 5116474,
<<          "negative": 58135783,
<<          "pending": 4118,
<<          "hospitalizedCurrently": 48500,
<<          "hospitalizedCumulative": 337062,
<<          "inIcuCurrently": 9136,
<<          "inIcuCumulative": 15331,
<<          "onVentilatorCurrently": 2415,
<<          "onVentilatorCumulative": 1612,
<<          "recovered": 1714960,
<<          "dateChecked": "2020-08-11T00:00:00Z",
<<          "death": 156273,
<<          "hospitalized": 337062,
<<          "lastModified": "2020-08-11T00:00:00Z",
<<          "total": 63256375,
<<          "totalTestResults": 63252257,
<<          "posNeg": 63252257,
<<          "deathIncrease": 1326,
<<          "hospitalizedIncrease": 2715,
<<          "negativeIncrease": 683489,
<<          "positiveIncrease": 55594,
<<          "totalTestResultsIncrease": 739083,
<<          "hash": "4b53c5c61a1b558e1b41cc8e6327f7359c17b4b1"
<<      }
<<  ]

</pre>

</details>

``` r
#> # A tibble: 1 x 25
#>   date       states positive negative pending hospitalized_cu… hospitalized_cu…
#>   <date>      <int>    <int>    <int>   <int>            <int>            <int>
#> 1 2020-08-11     56  5116474 58135783    4118            48500           337062
#> # … with 18 more variables: in_icu_currently <int>, in_icu_cumulative <int>,
#> #   on_ventilator_currently <int>, on_ventilator_cumulative <int>,
#> #   recovered <int>, date_checked <dttm>, death <int>, hospitalized <int>,
#> #   last_modified <chr>, total <int>, total_test_results <int>,
#> #   death_increase <int>, hospitalized_increase <int>, negative_increase <int>,
#> #   positive_increase <int>, total_test_results_increase <int>, hash <chr>,
#> #   request_datetime <dttm>
```

<sup>Created on 2020-08-12 by the [reprex
package](https://reprex.tidyverse.org) (v0.3.0.9001)</sup>

-----

Like the `reprex` package, `httrex` will try to read off your clipboard
if you leave the `x` and `input` arguments empty.
