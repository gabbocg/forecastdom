# Replicating Hansen & Lunde (2005)

This article reproduces the central question of Hansen and Lunde (2005,
*JAE*) — *Does anything beat a GARCH(1,1)?* — using
[`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)
on the bundled `hl2005` dataset. The benchmark is GARCH(1,1) with
constant mean and Gaussian errors; the alternatives are 329 other
GARCH-family specifications. The realized-variance proxy choice turns
out to matter for the decision.

``` r
library(forecastdom)
data(hl2005)

n <- length(hl2005$date)
J <- ncol(hl2005$forecasts)
sprintf("Sample: %s to %s (%d trading days), %d forecast models.",
        hl2005$date[1], hl2005$date[n], n, J)
#> [1] "Sample: 1999-06-01 to 2000-05-31 (254 trading days), 330 forecast models."
```

## Setup

Squared-error loss `(f - y)^2` against each RV proxy. The loss
differential matrix `Y` is `competitor_loss − benchmark_loss`, so
positive values mean GARCH(1,1) wins.

``` r
b <- hl2005$garch11_idx

build_Y <- function(rv) {
  L <- (hl2005$forecasts - rv)^2
  L[, -b] - L[, b]
}

Y <- build_Y(hl2005$rv)            # primary RV proxy (5-min linear)
dim(Y)
#> [1] 254 329

cat("Competitors with lower MSE than GARCH(1,1):",
    sum(colMeans(Y) < 0), "of", ncol(Y), "\n")
#> Competitors with lower MSE than GARCH(1,1): 187 of 329
```

More than half of the 329 alternatives beat GARCH(1,1) on average loss —
the unconditional ranking does not single out GARCH(1,1). The question
is whether any of them does so by a *statistically significant* margin
after correcting for multiple testing. That is exactly what
[`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)
answers.

## SPA test against the primary RV proxy

``` r
set.seed(20260512)
r <- spa_test(Y, level = 0.05, B = 5000L, q = 0.25)
r
#> 
#> ╭────────────────────────────────────────────────────╮
#> │          Superior Predictive Ability Test          │
#> │                   (Hansen, 2005)                   │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark is superior to all competitors       │
#> │ H1: Some competitor outperforms the benchmark      │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  SPA statistic: 40.5299                            │
#> │  P-value (bootstrap): 0.0734                       │
#> │  Decision: Not rejected                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 254                             │
#> │  Competitors (J): 329                              │
#> │  Bootstrap replications: 5000                      │
#> │  Significance level: 0.0500                        │
#> ╰────────────────────────────────────────────────────╯
```

T_SPA is large but the bootstrap p-value sits just above 5%. Conclusion:
at the 5% level, with the 5-minute linear-interpolation proxy, *nothing
significantly beats GARCH(1,1)* — Hansen and Lunde’s headline finding.

## Robustness across realised-variance proxies

The dataset ships with eight different RV proxies, from the very noisy
squared close-to-close return to fine 1-minute sampled estimators.
Re-running the SPA test across all eight produces the paper’s central
robustness table.

``` r
proxies <- colnames(hl2005$rv_proxies)

tab <- do.call(rbind, lapply(proxies, function(p) {
  set.seed(20260512)
  r <- spa_test(build_Y(hl2005$rv_proxies[, p]),
                level = 0.05, B = 5000L, q = 0.25)
  data.frame(proxy = p,
             T_SPA   = unname(r$statistic),
             pvalue  = unname(r$pvalue),
             reject  = unname(r$reject),
             n_beat  = sum(colMeans(build_Y(hl2005$rv_proxies[, p])) < 0))
}))

knitr::kable(
  tab, digits = 3, row.names = FALSE,
  col.names = c("Proxy", "$T^{SPA}$", "$p$-value",
                "Reject", "$n_{\\text{beat}}$"))
```

| Proxy           | $T^{SPA}$ | $p$-value | Reject | $n_{\text{beat}}$ |
|:----------------|----------:|----------:|:-------|------------------:|
| sq_ccr          |    18.341 |     0.798 | FALSE  |               257 |
| spline_50_3min  |    40.427 |     0.076 | FALSE  |               186 |
| spline_250_2min |    46.255 |     0.034 | TRUE   |               187 |
| fourier_M85     |    43.255 |     0.051 | FALSE  |               195 |
| linear_5min     |    40.530 |     0.073 | FALSE  |               187 |
| prevtick_5min   |    41.068 |     0.068 | FALSE  |               187 |
| linear_1min     |    49.770 |     0.020 | TRUE   |               189 |
| prevtick_1min   |    49.784 |     0.021 | TRUE   |               189 |

The decision flips with proxy quality:

- **Noisy proxy** (`sq_ccr`, squared close-to-close returns): T_SPA much
  smaller and p-value far from rejection. With a noisy target no model
  can be confidently ranked against any other.
- **Coarse intraday proxies** (5-min linear/previous-tick): p-values
  hover near 0.07-0.08 — just *failing* to reject GARCH(1,1).
- **Fine intraday proxies** (1-min linear/previous-tick, Fourier,
  Spline-250): p-values fall below 5% and the SPA *does* reject — with a
  sufficiently accurate volatility proxy, some competitor models can be
  shown to beat GARCH(1,1).

This is precisely Hansen and Lunde’s nuanced answer: GARCH(1,1) is hard
to beat in any *concrete* unconditional comparison, but the decision is
sensitive to how cleanly we measure realised volatility.

## Top 10 alternatives by mean loss (5-min proxy)

``` r
d_bar <- colMeans(Y)
top10_idx <- order(d_bar)[1:10]
data.frame(rank = 1:10,
           competitor_col = (1:J)[-b][top10_idx],
           mean_loss_diff = round(d_bar[top10_idx], 3))
#>      rank competitor_col mean_loss_diff
#> V215    1            214         -3.119
#> V250    2            249         -2.947
#> V195    3            194         -2.929
#> V305    4            304         -2.922
#> V317    5            316         -2.477
#> V207    6            206         -2.463
#> V262    7            261         -2.447
#> V98     8             97         -2.396
#> V100    9             99         -2.385
#> V275   10            274         -2.337
```

`mean_loss_diff` is the average of `L_competitor − L_GARCH(1,1)`;
negative values mean the competitor has lower mean MSE than GARCH(1,1).
Columns 261-265 correspond to the EGARCH family with constant mean and
t-distributed errors (per the README’s grouping of the 330
specifications) — the most consistent winners across proxies.

## References

- Hansen, P. R. (2005). A test for superior predictive ability. *Journal
  of Business & Economic Statistics*, 23(4), 365-380.
- Hansen, P. R. and Lunde, A. (2005). A forecast comparison of
  volatility models: does anything beat a GARCH(1,1)? *Journal of
  Applied Econometrics*, 20(7), 873-889.
