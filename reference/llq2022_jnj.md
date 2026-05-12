# Johnson & Johnson Realized-Variance Forecasts (Li, Liao & Quaedvlieg, 2022)

Daily 5-minute realized variance of Johnson & Johnson (NYSE: JNJ) with
one-step-ahead out-of-sample forecasts from six competing models, plus
one-day-lagged VIX as a conditioning variable. JNJ is the stock featured
in Figures 2 and 3 of Li, Liao and Quaedvlieg (2022).

## Usage

``` r
llq2022_jnj
```

## Format

A data frame with the same columns as
[`llq2022`](https://gabbocg.github.io/forecastdom/reference/llq2022.md):

- date:

  Trading-day `Date`.

- rv:

  Realized variance (5-minute returns), percent-squared.

- AR1, AR22, AR22_Lasso, HAR, HARQ, ARFIMA:

  One-step-ahead forecasts of `rv`.

- vix_lag:

  VIX close from the previous trading day.

## Source

Replication package of Li, Liao and Quaedvlieg (2022),
<https://zenodo.org/record/4884813>. Realized variance series from
Bollerslev, Patton and Quaedvlieg (2016). VIX from CBOE.

## References

Bollerslev, T., Patton, A. J. and Quaedvlieg, R. (2016). Exploiting the
errors: a simple approach for improved volatility forecasting. *Journal
of Econometrics*, 192(1), 1-18.

Li, J., Liao, Z. and Quaedvlieg, R. (2022). Conditional Superior
Predictive Ability. *Review of Economic Studies*, 89(2), 843-875.
