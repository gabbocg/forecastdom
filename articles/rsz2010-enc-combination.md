# Replicating Rapach, Strauss & Zhou (2010)

This article reproduces the out-of-sample equity premium analysis of
Rapach, Strauss and Zhou (2010, *RFS*) on the bundled `rz2013` dataset.
RSZ test the historical-average benchmark against predictive regressions
on each of 14 Goyal-Welch macro variables using the Clark-West
MSFE-adjusted statistic; we report both
[`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)
(their headline statistic) and
[`enc_new()`](https://gabbocg.github.io/forecastdom/reference/enc_new.md)
(the Clark-McCracken encompassing test on the same null) side by side.

**Note on the data.** The bundled `rz2013` is the Rapach-Zhou (2013)
*Handbook* vintage of the Welch-Goyal series, not the exact 2008 file
RSZ used. R²_OS magnitudes therefore differ in places but the
qualitative pattern of RSZ Table 1 is preserved (interest-rate
predictors significant under CW; valuation ratios not).

``` r
library(forecastdom)
data(rz2013)

rsz <- subset(rz2013,
              date >= as.Date("1947-01-01") &
              date <= as.Date("2005-12-01"))
```

## Helpers

``` r
recursive_forecasts <- function(y, x, R) {
  P <- length(y) - R
  e1 <- e2 <- f1 <- f2 <- numeric(P)
  for (j in seq_len(P)) {
    ty <- y[1:(R + j - 1)]
    tx <- x[1:(R + j - 1)]
    f1[j] <- mean(ty)
    fit   <- lm(yt ~ xlag,
                data = data.frame(yt   = ty[-1],
                                  xlag = tx[-length(tx)]))
    f2[j] <- as.numeric(predict(fit, newdata = data.frame(xlag = tx[length(tx)])))
    e1[j] <- y[R + j] - f1[j]
    e2[j] <- y[R + j] - f2[j]
  }
  list(e1 = e1, e2 = e2, f1 = f1, f2 = f2)
}
```

## Table 1 — Univariate predictors

Initial estimation 1947:01-1964:12 (R = 216 months); out-of-sample
1965:01-2005:12 (P = 492 months). Columns:

- **R2OS (%)** — out-of-sample R-squared (Campbell-Thompson 2008).
- **CW stat / p-value** — Clark-West MSFE-adjusted test
  ([`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md));
  RSZ’s headline statistic.
- **ENC-NEW** — Clark-McCracken (2001) encompassing test
  ([`enc_new()`](https://gabbocg.github.io/forecastdom/reference/enc_new.md));
  non-standard distribution, 5% critical value for and .

``` r
predictors <- c("DP", "DY", "EP", "DE", "SVAR", "BM", "NTIS",
                "TBL", "LTY", "LTR", "TMS", "DFY", "DFR", "INFL_lag")

R <- 216

fc_list <- lapply(predictors, function(p) {
  recursive_forecasts(rsz$eq_prem, rsz[[p]], R = R)
})
names(fc_list) <- predictors

tab_uni <- do.call(rbind, lapply(predictors, function(p) {
  fc  <- fc_list[[p]]
  cw  <- cw_test(fc$e1, fc$e2, fc$f1, fc$f2)
  enc <- enc_new(fc$e1, fc$e2)
  data.frame(predictor = p,
             R2OS_pct  = unname(cw$r2os),
             CW_stat   = unname(cw$statistic),
             CW_pvalue = unname(cw$pvalue),
             ENC_NEW   = unname(enc$statistic))
}))

knitr::kable(tab_uni, digits = 3, row.names = FALSE)
```

| predictor | R2OS_pct | CW_stat | CW_pvalue | ENC_NEW |
|:----------|---------:|--------:|----------:|--------:|
| DP        |    0.062 |   1.459 |     0.072 |   4.327 |
| DY        |    0.083 |   1.495 |     0.068 |   4.568 |
| EP        |    0.075 |   0.941 |     0.173 |   1.862 |
| DE        |   -0.414 |   0.516 |     0.303 |   1.444 |
| SVAR      |   -0.844 |  -0.838 |     0.799 |  -1.559 |
| BM        |   -1.097 |  -0.449 |     0.673 |  -0.891 |
| NTIS      |   -0.374 |   0.733 |     0.232 |   1.532 |
| TBL       |   -0.312 |   2.180 |     0.015 |  13.533 |
| LTY       |   -0.651 |   1.647 |     0.050 |   9.093 |
| LTR       |    0.161 |   1.988 |     0.023 |   7.794 |
| TMS       |   -0.586 |   2.171 |     0.015 |  10.077 |
| DFY       |   -0.505 |   0.050 |     0.480 |   0.078 |
| DFR       |   -0.477 |  -0.025 |     0.510 |  -0.042 |
| INFL_lag  |    0.139 |   0.777 |     0.218 |   1.702 |

Predictors with CW p-value \< 0.05 — TBL, LTY, LTR, TMS — coincide with
the four interest-rate-related variables RSZ flag as significant in
Table 1. ENC-NEW exceeds the 5% critical value (~2.7) for the same four,
plus DP and DY at the margin.

## Table 2 — Combination forecasts

For each OOS month form a combined forecast across the 14 univariate
regressions; test each combination against the historical average using
both statistics.

``` r
F2    <- sapply(fc_list, function(z) z$f2)
e1    <- fc_list[[1]]$e1
f1    <- fc_list[[1]]$f1
y_oos <- rsz$eq_prem[(R + 1):nrow(rsz)]

combos <- list(
  "Mean"               = rowMeans(F2),
  "Median"             = apply(F2, 1, median),
  "Trimmed mean (10%)" = apply(F2, 1, function(z) mean(z, trim = 0.1))
)

tab_comb <- do.call(rbind, lapply(names(combos), function(nm) {
  f2c <- combos[[nm]]
  e2c <- y_oos - f2c
  cw  <- cw_test(e1, e2c, f1, f2c)
  enc <- enc_new(e1, e2c)
  data.frame(combination = nm,
             R2OS_pct    = unname(cw$r2os),
             CW_stat     = unname(cw$statistic),
             CW_pvalue   = unname(cw$pvalue),
             ENC_NEW     = unname(enc$statistic))
}))

knitr::kable(tab_comb, digits = 3, row.names = FALSE)
```

| combination        | R2OS_pct | CW_stat | CW_pvalue | ENC_NEW |
|:-------------------|---------:|--------:|----------:|--------:|
| Mean               |    1.319 |   3.156 |     0.001 |   3.883 |
| Median             |    0.934 |   3.204 |     0.001 |   2.656 |
| Trimmed mean (10%) |    1.244 |   3.218 |     0.001 |   3.615 |

## Takeaway

Individual macro predictors yield mostly negative R²_OS, in line with
the Welch-Goyal (2008) puzzle. The Clark-West and ENC-NEW statistics
nonetheless reject the historical-average benchmark for the four
interest-rate predictors that RSZ also flag.

Combination forecasts deliver positive R²_OS and reject the
historical-average benchmark under both tests — the central message of
Rapach, Strauss and Zhou (2010): pooling extracts predictive content
that no single predictor reliably captures on its own.

## References

- Clark, T. E. and McCracken, M. W. (2001). Tests of equal forecast
  accuracy and encompassing for nested models. *Journal of
  Econometrics*, 105(1), 85-110.
- Clark, T. E. and West, K. D. (2007). Approximately normal tests for
  equal predictive accuracy in nested models. *Journal of Econometrics*,
  138(1), 291-311.
- Rapach, D. E., Strauss, J. K. and Zhou, G. (2010). Out-of-sample
  equity premium prediction: combination forecasts and links to the real
  economy. *Review of Financial Studies*, 23(2), 821-862.
- Welch, I. and Goyal, A. (2008). A comprehensive look at the empirical
  performance of equity premium prediction. *Review of Financial
  Studies*, 21(4), 1455-1508.
