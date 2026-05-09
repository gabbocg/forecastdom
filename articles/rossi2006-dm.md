# Diebold-Mariano on Exchange Rates (Rossi, 2006)

This article reproduces the spirit of the out-of-sample test in Rossi
(2006), *“Are exchange rates really random walks? Some evidence robust
to parameter instability”* (*Macroeconomic Dynamics*, 10(1), 20-38),
using the
[`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md)
function from **forecastdom** and the bundled `rossi2006` dataset.

The exercise asks a classical question from Meese and Rogoff (1983): can
a linear AR model of monthly exchange-rate returns produce out-of-sample
forecasts that beat a driftless random walk?

``` r
library(forecastdom)
library(ggplot2)

data(rossi2006)
str(rossi2006)
#> 'data.frame':    1550 obs. of  3 variables:
#>  $ date   : Date, format: "1973-03-01" "1973-04-01" ...
#>  $ country: Factor w/ 5 levels "Canada","France",..: 1 1 1 1 1 1 1 1 1 1 ...
#>  $ fx     : num  100.1 99.7 100.5 100.2 99.8 ...
```

## The data

Five bilateral nominal exchange rates against the U.S. dollar (Canada,
France, Germany, Italy, Japan), monthly from March 1973 to December 1998
— 310 observations per country.

``` r
ggplot(rossi2006, aes(date, log(fx))) +
  geom_line(colour = "#47A5C5") +
  facet_wrap(~ country, scales = "free_y") +
  labs(x = NULL, y = "log(FX)",
       title = "Log nominal exchange rates vs. USD") +
  theme_minimal(base_size = 11)
```

![](rossi2006-dm_files/figure-html/plot-fx-1.png)

## The forecasting exercise

Let $e_{t}$ denote the log exchange rate and
$\Delta e_{t} = e_{t} - e_{t - 1}$ its monthly return. Two competing
one-step-ahead forecasts of $\Delta e_{t + 1}$:

- **Benchmark — driftless random walk:**
  ${\widehat{\Delta e}}_{t + 1}^{RW} = 0$.
- **Competitor — AR(1):**
  ${\widehat{\Delta e}}_{t + 1}^{AR} = {\widehat{\alpha}}_{t} + {\widehat{\beta}}_{t}\,\Delta e_{t}$,
  with $\left( {\widehat{\alpha}}_{t},{\widehat{\beta}}_{t} \right)$
  re-estimated by OLS on an expanding (recursive) window.

Following Rossi (2006), the first $R = \lfloor T/2\rfloor$ observations
are used as the initial estimation window, and the test is run on the
remaining $P = T - R$ periods.

``` r
forecast_ar1_vs_rw <- function(log_fx) {
  dlog <- diff(log_fx)
  T_   <- length(dlog)
  R    <- floor(T_ / 2)
  P    <- T_ - R

  e_ar <- numeric(P)
  e_rw <- numeric(P)

  for (j in seq_len(P)) {
    train <- dlog[seq_len(R + j - 1)]
    fit   <- lm(y ~ x, data = data.frame(y = train[-1], x = train[-length(train)]))
    f_ar  <- as.numeric(predict(fit, newdata = data.frame(x = train[length(train)])))
    realised <- dlog[R + j]

    e_ar[j] <- realised - f_ar
    e_rw[j] <- realised - 0
  }

  list(e_ar = e_ar, e_rw = e_rw, P = P)
}
```

## Country-by-country DM test

[`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md)
takes the two error series and returns the Diebold-Mariano statistic
with the Harvey-Leybourne-Newbold (1997) small-sample correction by
default. The benchmark is the random walk (`e1`); the competitor is the
AR(1) (`e2`).

``` r
countries <- levels(rossi2006$country)

dm_results <- lapply(countries, function(co) {
  log_fx <- log(subset(rossi2006, country == co)$fx)
  fc     <- forecast_ar1_vs_rw(log_fx)
  res    <- dm_test(fc$e_rw, fc$e_ar, h = 1, loss = "SE",
                    alternative = "two.sided")
  data.frame(
    country   = co,
    P         = fc$P,
    dm_stat   = unname(res$statistic),
    p_value   = unname(res$pvalue)
  )
})

dm_table <- do.call(rbind, dm_results)
knitr::kable(dm_table, digits = 4,
             caption = "Modified DM test, AR(1) vs. driftless random walk")
```

| country |   P | dm_stat | p_value |
|:--------|----:|--------:|--------:|
| Canada  | 155 | -1.3378 |  0.1829 |
| France  | 155 | -2.2106 |  0.0285 |
| Germany | 155 | -0.1731 |  0.8628 |
| Italy   | 155 | -0.9478 |  0.3447 |
| Japan   | 155 |  0.1184 |  0.9059 |

Modified DM test, AR(1) vs. driftless random walk

A negative `dm_stat` would indicate the AR(1) has *lower* squared-error
loss than the random walk; a positive one favours the random walk. Under
the two-sided alternative, p-values close to 1 are consistent with the
Meese-Rogoff result that the random walk is hard to beat at short
horizons.

## A single-country deep dive: Japan

Inspecting one country in more detail. The print method shows the test
configuration and a t-distribution reference (because HLN is on by
default).

``` r
log_fx_jp <- log(subset(rossi2006, country == "Japan")$fx)
fc_jp     <- forecast_ar1_vs_rw(log_fx_jp)
dm_test(fc_jp$e_rw, fc_jp$e_ar, alternative = "two.sided")
#> 
#> ╭────────────────────────────────────────────────────╮
#> │     Modified Diebold-Mariano Test (HLN, 1997)      │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Equal predictive ability                       │
#> │ H1: Methods have different predictive ability      │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  DM statistic: 0.1184                              │
#> │  P-value: 0.9059                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 155                             │
#> │  Forecast horizon (h): 1                           │
#> │  Loss function: SE                                 │
#> │  Reference distribution: t(154)                    │
#> ╰────────────────────────────────────────────────────╯
```

The cumulative loss differential is a useful diagnostic: it tracks
whether either method dominates persistently or only over short
sub-samples.

``` r
loss_diff <- fc_jp$e_rw^2 - fc_jp$e_ar^2
oos_dates <- tail(unique(rossi2006$date), fc_jp$P)

ggplot(data.frame(date = oos_dates, cum = cumsum(loss_diff)),
       aes(date, cum)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line(colour = "#47A5C5", linewidth = 0.8) +
  labs(x = NULL,
       y = "Cumulative SE loss (RW - AR(1))",
       title = "Cumulative squared-error loss differential, Japan",
       subtitle = "Above zero = AR(1) doing better; below = RW doing better") +
  theme_minimal(base_size = 11)
```

![](rossi2006-dm_files/figure-html/cum-loss-1.png)

## Takeaways

- [`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md)
  plugs straight into a standard recursive forecasting loop and returns
  the HLN-corrected statistic with t-distribution p-values out of the
  box.
- For these five rates and this sample, the test typically fails to
  reject equal predictive accuracy — consistent with Meese and Rogoff
  1983. and the broader exchange-rate forecasting literature.
- The cumulative loss-differential plot complements the single number,
  showing *when* the relative performance of the two models shifts — the
  kind of instability that motivates Rossi’s parameter-instability tests
  in the original paper.

## References

- Diebold, F. X. and Mariano, R. S. (1995). Comparing predictive
  accuracy. *Journal of Business & Economic Statistics*, 13(3), 253-263.
- Harvey, D., Leybourne, S., and Newbold, P. (1997). Testing the
  equality of prediction mean squared errors. *International Journal of
  Forecasting*, 13(2), 281-291.
- Meese, R. A. and Rogoff, K. (1983). Empirical exchange rate models of
  the seventies: Do they fit out of sample? *Journal of International
  Economics*, 14(1-2), 3-24.
- Rossi, B. (2006). Are exchange rates really random walks? Some
  evidence robust to parameter instability. *Macroeconomic Dynamics*,
  10(1), 20-38.
