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

  Character; alternative hypothesis. `"two.sided"` (default), `"less"`
  (model 2 is better), or `"greater"` (model 1 is better).

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
#> │  DM statistic: 1.5039                              │
#> │  P-value: 0.1358                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 100                             │
#> │  Forecast horizon (h): 1                           │
#> │  Loss function: SE                                 │
#> │  Reference distribution: t(99)                     │
#> ╰────────────────────────────────────────────────────╯
#> 
```
