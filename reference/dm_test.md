# Diebold-Mariano Test for Equal Predictive Ability

Tests the null hypothesis that two forecasting methods have equal
predictive ability (UEPA), with an optional small-sample correction by
Harvey, Leybourne, and Newbold (1997).

## Usage

``` r
dm_test(
  e1,
  e2,
  h = 1L,
  loss = c("SE", "AE"),
  alternative = c("two.sided", "less", "greater"),
  correction = TRUE
)
```

## Arguments

- e1:

  Numeric vector of forecast errors from model 1 (benchmark).

- e2:

  Numeric vector of forecast errors from model 2 (competitor).

- h:

  Integer; forecast horizon. Default `1`.

- loss:

  Character; loss function to use. `"SE"` for squared error (default),
  `"AE"` for absolute error.

- alternative:

  Character; alternative hypothesis about the loss differential \\d_t =
  L(e\_{1,t}) - L(e\_{2,t})\\. `"two.sided"` (default); `"less"`, model
  2 is less accurate than model 1 (\\E\[d_t\] \< 0\\); or `"greater"`,
  model 2 is more accurate than model 1 (\\E\[d_t\] \> 0\\). This is the
  convention of
  [`forecast::dm.test()`](https://pkg.robjhyndman.com/forecast/reference/dm.test.html).

- correction:

  Logical; apply the Harvey, Leybourne, and Newbold (1997) finite-sample
  correction? Default `TRUE`.

## Value

A list with class `"dm_test"` containing:

- statistic:

  The (possibly corrected) DM test statistic.

- pvalue:

  P-value.

- alternative:

  The alternative hypothesis used.

- correction:

  Whether HLN correction was applied.

- h:

  Forecast horizon.

- n:

  Number of observations.

- loss:

  Loss function used.

## Details

The long-run variance of \\d_t\\ sums its autocovariances up to lag
\\h - 1\\ with equal weights, each divided by \\n\\, as in Diebold and
Mariano (1995) and
[`forecast::dm.test()`](https://pkg.robjhyndman.com/forecast/reference/dm.test.html).
With the correction, the statistic equals that of
[`forecast::dm.test()`](https://pkg.robjhyndman.com/forecast/reference/dm.test.html).
For \\h \> 1\\ the estimate can be negative, and `dm_test()` then stops
with an error.

## References

Diebold, F.X. and Mariano, R.S. (1995). Comparing Predictive Accuracy.
*Journal of Business & Economic Statistics*, 13(3), 253-263.

Harvey, D., Leybourne, S., and Newbold, P. (1997). Testing the Equality
of Prediction Mean Squared Errors. *International Journal of
Forecasting*, 13(2), 281-291.

## Examples

``` r
set.seed(42)
e1 <- rnorm(100)
e2 <- rnorm(100, mean = 0.1)
dm_test(e1, e2)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │     Modified Diebold-Mariano Test (HLN, 1997)      │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Equal predictive ability                       │
#> │ H1: Methods have different predictive ability      │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  DM statistic: 1.5115                              │
#> │  P-value: 0.1338                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 100                             │
#> │  Forecast horizon (h): 1                           │
#> │  Loss function: SE                                 │
#> │  Reference distribution: t(99)                     │
#> ╰────────────────────────────────────────────────────╯
#> 
```
