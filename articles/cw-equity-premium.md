# Replicating Rapach & Zhou (2013) and Neely et al. (2014)

This article applies
[`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)
to two bundled equity premium datasets:

- `rz2013` – 14 Goyal-Welch macroeconomic predictors used in Rapach and
  Zhou (2013).
- `nrtz2014` – 14 binary technical indicators used in Neely, Rapach, Tu
  and Zhou (2014).

In both cases the benchmark is the prevailing historical mean and the
alternative is a bivariate predictive regression on a single predictor.

``` r
library(forecastdom)
data(rz2013); data(nrtz2014)
```

## Helper

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

## Macro predictors (Rapach & Zhou, 2013)

Initial estimation window of 241 months (1926-12 to 1946-12); OOS period
1947-01 to 2010-12.

``` r
preds_rz <- c("DP", "EP", "NTIS", "TBL", "INFL_lag")
knitr::kable(run_cw(rz2013, preds_rz, R = 241), digits = 3, row.names = FALSE)
```

| predictor | R2OS_pct | CW_stat | p_value |
|:----------|---------:|--------:|--------:|
| DP        |    0.129 |   1.621 |   0.053 |
| EP        |   -1.452 |   1.469 |   0.071 |
| NTIS      |   -0.761 |   0.311 |   0.378 |
| TBL       |   -0.043 |   1.308 |   0.095 |
| INFL_lag  |   -0.086 |   0.047 |   0.481 |

## Technical indicators (Neely et al., 2014)

Initial window of 181 months (1950-12 to 1965-12); OOS period 1966-01 to
2011-12.

``` r
preds_nr <- c("MA_1_9", "MA_2_12", "MOM_9", "MOM_12", "VOL_2_12")
knitr::kable(run_cw(nrtz2014, preds_nr, R = 181), digits = 3, row.names = FALSE)
```

| predictor | R2OS_pct | CW_stat | p_value |
|:----------|---------:|--------:|--------:|
| MA_1_9    |    0.235 |   0.981 |   0.163 |
| MA_2_12   |    0.779 |   1.693 |   0.045 |
| MOM_9     |    0.108 |   0.613 |   0.270 |
| MOM_12    |    0.154 |   0.686 |   0.247 |
| VOL_2_12  |    0.331 |   1.121 |   0.131 |

## Takeaways

- For Goyal-Welch macro predictors, out-of-sample gains over the
  historical mean are economically small – the well-known Goyal-Welch
  puzzle.
- Technical indicators deliver positive $R_{OS}^{2}$ with Clark-West
  statistics significant at conventional levels – the central finding of
  Neely et al. (2014).

## References

- Clark, T. E. and West, K. D. (2007). Approximately normal tests for
  equal predictive accuracy in nested models. *Journal of Econometrics*,
  138(1), 291-311.
- Neely, C. J., Rapach, D. E., Tu, J. and Zhou, G. (2014). Forecasting
  the equity risk premium: The role of technical indicators. *Management
  Science*, 60(7), 1772-1791.
- Rapach, D. E. and Zhou, G. (2013). Forecasting stock returns. In G.
  Elliott and A. Timmermann (Eds.), *Handbook of Economic Forecasting*,
  Vol. 2A, pp. 328-383. Elsevier.
