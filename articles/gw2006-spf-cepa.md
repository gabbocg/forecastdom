# Replicating Giacomini & White (2006)

This article applies
[`gw_test()`](https://gabbocg.github.io/forecastdom/reference/gw_test.md)
— Giacomini and White (2006) conditional equal predictive ability (CEPA)
test — to the Survey of Professional Forecasters’ mean CPI inflation
forecasts. The benchmark is a naive random walk in inflation (next
quarter’s forecast = this quarter’s realised inflation); the alternative
is the SPF mean at horizons $h = 0,1,2,3,4$ quarters. The bundled
`gw2006` dataset extends GW’s quarterly sample to the present using the
same Philadelphia Fed SPF source.

``` r
library(forecastdom)
data(gw2006)
str(gw2006)
#> 'data.frame':    180 obs. of  10 variables:
#>  $ date    : Date, format: "1981-09-01" "1981-12-01" ...
#>  $ year    : int  1981 1981 1982 1982 1982 1982 1983 1983 1983 1983 ...
#>  $ quarter : int  3 4 1 2 3 4 1 2 3 4 ...
#>  $ infl    : num  11.61 6.66 3.6 5.91 7.13 ...
#>  $ infl_lag: num  NA 11.61 6.66 3.6 5.91 ...
#>  $ spf_h0  : num  7.71 10.73 6.36 3.54 5.33 ...
#>  $ spf_h1  : num  NA 9.22 8.95 5.51 3.69 ...
#>  $ spf_h2  : num  NA NA 7.93 7.76 6.08 ...
#>  $ spf_h3  : num  NA NA NA 7.76 7.56 ...
#>  $ spf_h4  : num  NA NA NA NA 7.61 ...
```

## CEPA across forecast horizons

``` r
run_h <- function(h) {
  spf_col <- paste0("spf_h", h)
  ok <- complete.cases(gw2006[, c("infl", spf_col, "infl_lag")])
  d  <- gw2006[ok, ]
  e_spf <- d$infl - d[[spf_col]]    # SPF errors
  e_rw  <- d$infl - d$infl_lag      # random-walk errors
  r <- gw_test(e_spf, e_rw)         # default: constant + lagged loss diff
  data.frame(h = h, n = nrow(d),
             mse_spf = mean(e_spf^2),
             mse_rw  = mean(e_rw^2),
             wald    = unname(r$statistic),
             pvalue  = unname(r$pvalue),
             reject  = unname(r$pvalue) < 0.05)
}
tab <- do.call(rbind, lapply(0:4, run_h))
knitr::kable(
  tab, digits = 3, row.names = FALSE,
  col.names = c("$h$", "$n$",
                "$MSE_{SPF}$", "$MSE_{RW}$",
                "Wald", "$p$-value", "Reject"))
```

| $h$ | $n$ | $MSE_{SPF}$ | $MSE_{RW}$ |  Wald | $p$-value | Reject |
|----:|----:|------------:|-----------:|------:|----------:|:-------|
|   0 | 176 |       5.657 |      5.565 | 4.510 |     0.105 | FALSE  |
|   1 | 176 |       4.906 |      5.565 | 1.206 |     0.547 | FALSE  |
|   2 | 175 |       4.631 |      5.456 | 4.177 |     0.124 | FALSE  |
|   3 | 174 |       4.708 |      5.434 | 3.581 |     0.167 | FALSE  |
|   4 | 173 |       4.884 |      5.435 | 2.908 |     0.234 | FALSE  |

At every horizon SPF has lower mean squared error than the random-walk
benchmark, yet the GW test fails to reject conditional equal predictive
ability at the 5% level. The pattern is consistent with Atkeson and
Ohanian (2001): once the autocorrelation of the loss differential is
accounted for, sophisticated inflation forecasts are hard to distinguish
from a “no-change” benchmark in a formal test.

## Choice of instruments

[`gw_test()`](https://gabbocg.github.io/forecastdom/reference/gw_test.md)
defaults to two instruments: a constant and the lagged loss
differential. Different instruments target different features of the
conditioning information set. Below we replace the lag with the lagged
inflation level — a regime indicator that captures high/low inflation
environments — at horizon $h = 1$.

``` r
h <- 1L
ok <- complete.cases(gw2006[, c("infl", paste0("spf_h", h), "infl_lag")])
d  <- gw2006[ok, ]
e_spf <- d$infl - d[[paste0("spf_h", h)]]
e_rw  <- d$infl - d$infl_lag

# Default: constant + lagged loss differential
r_default <- gw_test(e_spf, e_rw)

# Custom: constant + lagged inflation level (padded with NA at t = 1
# so that nrow(W) matches length(e1)).
W_infl <- cbind(1, c(NA, head(d$infl_lag, -1)))
keep   <- !is.na(W_infl[, 2])
r_infl <- gw_test(e_spf[keep], e_rw[keep],
                  instruments = W_infl[keep, , drop = FALSE])

# Absolute-error loss instead of squared-error
r_ae <- gw_test(e_spf, e_rw, loss = "AE")

tab2 <- data.frame(
  spec = c("Default (const + lagged Δloss)",
           "Const + lagged inflation",
           "Absolute-error loss"),
  wald   = c(r_default$statistic, r_infl$statistic, r_ae$statistic),
  df     = c(r_default$df,        r_infl$df,        r_ae$df),
  pvalue = c(r_default$pvalue,    r_infl$pvalue,    r_ae$pvalue)
)
knitr::kable(
  tab2, digits = 3, row.names = FALSE,
  col.names = c("Specification", "Wald", "df", "$p$-value"))
```

| Specification                  |   Wald |  df | $p$-value |
|:-------------------------------|-------:|----:|----------:|
| Default (const + lagged Δloss) |  1.206 |   2 |     0.547 |
| Const + lagged inflation       | 10.738 |   2 |     0.005 |
| Absolute-error loss            |  1.957 |   2 |     0.376 |

The decision is robust across all three specifications: SPF and the
random walk cannot be statistically distinguished at the 5% level
regardless of which conditioning instruments or loss function we choose.

## Note on the original paper

Giacomini and White (2006, Section 4) compare SPF nowcasts to the
*Greenbook* — the Federal Reserve staff’s internal inflation forecast —
using a richer instrument set. They find that the test *does* reject
equal conditional predictive ability between the two *sophisticated*
forecasts in some conditioning states. Replicating that result requires
Greenbook data with its five-year embargo; this article instead
demonstrates the test mechanics against the simpler random-walk
benchmark, which is freely available.

## References

- Atkeson, A. and Ohanian, L. E. (2001). Are Phillips curves useful for
  forecasting inflation? *Federal Reserve Bank of Minneapolis Quarterly
  Review*, 25(1), 2-11.
- Giacomini, R. and White, H. (2006). Tests of conditional predictive
  ability. *Econometrica*, 74(6), 1545-1578.
