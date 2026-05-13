# Replicating Rapach & Zhou (2013)

This article applies
[`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)
to the `rz2013` bundled dataset: the 14 Goyal-Welch macroeconomic
predictors used in Rapach and Zhou (2013) to forecast the U.S. equity
premium. The benchmark is the prevailing historical mean and the
alternative is a bivariate predictive regression on a single macro
variable.

``` r
library(forecastdom)
data(rz2013)
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
    fit   <- lm(yt ~ xlag, data = data.frame(yt = ty[-1], xlag = tx[-length(tx)]))
    f2[j] <- as.numeric(predict(fit, newdata = data.frame(xlag = tx[length(tx)])))
    e1[j] <- y[R + j] - f1[j]
    e2[j] <- y[R + j] - f2[j]

  }

  list(e1 = e1, e2 = e2, f1 = f1, f2 = f2)

}

run_cw <- function(data, predictors, R) {

  do.call(rbind, lapply(predictors, function(p) {

    fc  <- recursive_forecasts(data$eq_prem, data[[p]], R = R)
    res <- cw_test(fc$e1, fc$e2, fc$f1, fc$f2)
    data.frame(predictor = p,
               R2OS_pct  = unname(res$r2os),
               CW_stat   = unname(res$statistic),
               p_value   = unname(res$pvalue))

  }))

}
```

## Macro predictors

Initial estimation window of 241 months (1926-12 to 1946-12);
out-of-sample period 1947-01 to 2010-12.

``` r
preds_rz <- c("DP", "EP", "NTIS", "TBL", "INFL_lag")

knitr::kable(
  run_cw(rz2013, preds_rz, R = 241), digits = 3, row.names = FALSE,
  col.names = c("Predictor", "$R^2_{OS}$ (%)", "CW stat", "$p$-value"))
```

| Predictor | $R_{OS}^{2}$ (%) | CW stat | $p$-value |
|:----------|-----------------:|--------:|----------:|
| DP        |            0.129 |   1.621 |     0.053 |
| EP        |           -1.452 |   1.469 |     0.071 |
| NTIS      |           -0.761 |   0.311 |     0.378 |
| TBL       |           -0.043 |   1.308 |     0.095 |
| INFL_lag  |           -0.086 |   0.047 |     0.481 |

## Takeaway

Out-of-sample gains over the historical mean are economically small
across the Goyal-Welch macro predictors — the well-known Goyal-Welch
puzzle that motivated Rapach and Zhou (2013).

## References

- Clark, T. E. and West, K. D. (2007). Approximately normal tests for
  equal predictive accuracy in nested models. *Journal of Econometrics*,
  138(1), 291-311.
- Rapach, D. E. and Zhou, G. (2013). Forecasting stock returns. In G.
  Elliott and A. Timmermann (Eds.), *Handbook of Economic Forecasting*,
  Vol. 2A, pp. 328-383. Elsevier.
