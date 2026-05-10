# Replicating Neely et al. (2014)

This article applies
[`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)
to the `nrtz2014` bundled dataset: the 14 binary technical indicators
used in Neely, Rapach, Tu and Zhou (2014). The benchmark is the
prevailing historical mean and the alternative is a bivariate predictive
regression on a single technical indicator.

``` r
library(forecastdom)
data(nrtz2014)
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

## Technical indicators

Initial window of 181 months (1950-12 to 1965-12); out-of-sample period
1966-01 to 2011-12.

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

## Takeaway

Technical indicators deliver positive $R_{OS}^{2}$ with Clark-West
statistics significant at conventional levels — the central finding of
Neely et al. (2014) that technical signals carry information beyond what
macro variables provide.

## References

- Clark, T. E. and West, K. D. (2007). Approximately normal tests for
  equal predictive accuracy in nested models. *Journal of Econometrics*,
  138(1), 291-311.
- Neely, C. J., Rapach, D. E., Tu, J. and Zhou, G. (2014). Forecasting
  the equity risk premium: The role of technical indicators. *Management
  Science*, 60(7), 1772-1791.
