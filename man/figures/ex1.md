``` r
library(covid19us)
get_us_current()
```

<details style="margin-bottom:10px;margin-left:20px">

<summary>
\-\> GET /api/v1/us.json HTTP/2
</summary>

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
<- cache-control: max-age=600
<- content-encoding: gzip
<- content-length: 341
<- content-type: application/json; charset=utf-8
<- date: Wed, 12 Aug 2020 19:12:26 GMT
<- last-modified: Wed, 12 Aug 2020 18:21:43 GMT
<- server: Netlify
<- strict-transport-security: max-age=31556952
<- x-github-request-id: 232A:7DD7:E1E1D:11720B:5F34336E
<- x-origin-cache: HIT
<- x-proxy-cache: MISS
<- age: 504
<- etag: W/"5f343337-278"
<- expires: Wed, 12 Aug 2020 18:32:39 GMT
<- via: 1.1 varnish
<- x-cache: HIT
<- x-cache-hits: 7
<- x-fastly-request-id: 21bf4670e9362520cbfae1f8a94fac12603c1e48
<- x-served-by: cache-ewr18152-EWR
<- x-timer: S1597259546.222128,VS0,VE0
<- vary: Accept-Encoding
<- x-nf-request-id: 020a774c-ef7a-4336-b4ab-44d548a7ee89-2402091
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

<sup>Created on 2020-08-12 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0.9001)</sup>
