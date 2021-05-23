*Local `.Rprofile` detected at `/private/var/folders/jz/_z0s56ks2ln8tkplzgybp6p80000gn/T/RtmpebePCe/file125237b26f61/.Rprofile`*

``` r
x <- WikipediR::page_backlinks(
    "en", 
    "wikipedia", 
    page = "R_(programming_language)", 
    limit = 2
)
#> -> GET /w/api.php?action=query&list=backlinks&bltitle=R_%28programming_language%29&bldir=ascending&bllimit=2&format=json HTTP/2
#> -> Host: en.wikipedia.org
#> -> User-Agent: WikipediR - https://github.com/Ironholds/WikipediR
#> -> Accept-Encoding: deflate, gzip
#> -> Accept: application/json, text/xml, application/xml, */*
#> -> 
#> <- HTTP/2 200 
#> <- date: Sun, 23 May 2021 19:46:13 GMT
#> <- server: mw1392.eqiad.wmnet
#> <- x-content-type-options: nosniff
#> <- p3p: CP="See https://en.wikipedia.org/wiki/Special:CentralAutoLogin/P3P for more info."
#> <- x-frame-options: SAMEORIGIN
#> <- content-disposition: inline; filename=api-result.json
#> <- vary: Accept-Encoding,Treat-as-Untrusted,X-Forwarded-Proto,Cookie,Authorization
#> <- cache-control: private, must-revalidate, max-age=0
#> <- content-type: application/json; charset=utf-8
#> <- content-encoding: gzip
#> <- age: 0
#> <- x-cache: cp2033 miss, cp2027 pass
#> <- x-cache-status: pass
#> <- server-timing: cache;desc="pass", host;desc="cp2027"
#> <- strict-transport-security: max-age=106384710; includeSubDomains; preload
#> <- report-to: { "group": "wm_nel", "max_age": 86400, "endpoints": [{ "url": "https://intake-logging.wikimedia.org/v1/events?stream=w3c.reportingapi.network_error&schema_uri=/w3c/reportingapi/network_error/1.0.0" }] }
#> <- nel: { "report_to": "wm_nel", "max_age": 86400, "failure_fraction": 0.05, "success_fraction": 0.0}
#> <- permissions-policy: interest-cohort=()
#> <- set-cookie: WMF-Last-Access=23-May-2021;Path=/;HttpOnly;secure;Expires=Thu, 24 Jun 2021 12:00:00 GMT
#> <- set-cookie: WMF-Last-Access-Global=23-May-2021;Path=/;Domain=.wikipedia.org;HttpOnly;secure;Expires=Thu, 24 Jun 2021 12:00:00 GMT
#> <- x-client-ip: 68.46.13.206
#> <- set-cookie: GeoIP=US:MN:Saint_Paul:44.95:-93.16:v4; Path=/; secure; Domain=.wikipedia.org
#> <- accept-ranges: bytes
#> <- content-length: 155
#> <- 
#> <<  {
#> <<      "batchcomplete": "",
#> <<      "continue": {
#> <<          "blcontinue": "0|3878",
#> <<          "continue": "-||"
#> <<      },
#> <<      "query": {
#> <<          "backlinks": [
#> <<              {
#> <<                  "pageid": 1242,
#> <<                  "ns": 0,
#> <<                  "title": "Ada (programming language)"
#> <<              },
#> <<              {
#> <<                  "pageid": 1451,
#> <<                  "ns": 0,
#> <<                  "title": "APL (programming language)"
#> <<              }
#> <<          ]
#> <<      }
#> <<  }
x$query
#> $backlinks
#> $backlinks[[1]]
#> $backlinks[[1]]$pageid
#> [1] 1242
#> 
#> $backlinks[[1]]$ns
#> [1] 0
#> 
#> $backlinks[[1]]$title
#> [1] "Ada (programming language)"
#> 
#> 
#> $backlinks[[2]]
#> $backlinks[[2]]$pageid
#> [1] 1451
#> 
#> $backlinks[[2]]$ns
#> [1] 0
#> 
#> $backlinks[[2]]$title
#> [1] "APL (programming language)"
```

<sup>Created on 2021-05-23 by the [reprex package](https://reprex.tidyverse.org) (v2.0.0)</sup>
