# Clark-West Test for Predictive Ability of Nested Models

Tests whether an alternative (unrestricted) model has superior
out-of-sample predictive ability relative to a benchmark (restricted)
model, using the MSFE-adjusted statistic of Clark and West (2007). Also
computes the out-of-sample \\R^2\_{OS}\\ statistic.

## Usage

``` r
cw_test(e1, e2, f1, f2, h = 1L, nlag = NULL)
```

## Arguments

- e1:

  Numeric vector of forecast errors from the benchmark (restricted/null)
  model.

- e2:

  Numeric vector of forecast errors from the alternative (unrestricted)
  model.

- f1:

  Numeric vector of forecasts from the benchmark model.

- f2:

  Numeric vector of forecasts from the alternative model.

- h:

  Integer; forecast horizon. Default `1`.

- nlag:

  Non-negative integer; number of Newey-West lags. If `NULL` (default),
  uses `0` for `h = 1` and `floor(1.5 * h)` otherwise.

## Value

A list with class `"cw_test"` containing:

- statistic:

  The Clark-West t-statistic.

- pvalue:

  One-sided p-value (H1: alternative is better).

- r2os:

  Out-of-sample \\R^2\_{OS}\\ in percent.

- n:

  Number of observations.

- h:

  Forecast horizon.

- nlag:

  Number of Newey-West lags used.

## Details

The MSFE-adjusted series is defined as: \$\$\hat{f}\_t = e\_{1,t}^2 -
\left(e\_{2,t}^2 - (f\_{1,t} - f\_{2,t})^2\right)\$\$ The test regresses
\\\hat{f}\_t\\ on a constant and uses the resulting t-statistic,
compared to a standard normal distribution (one-sided).

The standard error is Newey-West (Bartlett weights, autocovariances
divided by \\n\\) with `nlag` lags. Overlapping \\h\\-step forecasts
make \\\hat{f}\_t\\ serially correlated up to lag \\h - 1\\, which the
least squares standard error ignores. The default bandwidth of \\1.5h\\
follows Clark and West (2007, Section 5); with exactly \\h - 1\\ lags
the Bartlett weights shrink those autocovariances and the test
over-rejects. For `h = 1` the standard error is the sample standard
deviation over \\\sqrt{n}\\, which differs from the least squares one by
the factor \\\sqrt{(n - 1)/n}\\.

## References

Clark, T.E. and West, K.D. (2007). Approximately Normal Tests for Equal
Predictive Accuracy in Nested Models. *Journal of Econometrics*, 138(1),
291-311.

## Examples

``` r
set.seed(42)
n <- 200
actual <- rnorm(n)
f1 <- actual + rnorm(n, sd = 0.5)
f2 <- actual + rnorm(n, sd = 0.4)
e1 <- actual - f1
e2 <- actual - f2
cw_test(e1, e2, f1, f2)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │               Clark-West Test (2007)               │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark MSFE <= Alternative MSFE             │
#> │ H1: Alternative model is superior (R2OS > 0)       │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  CW statistic: 9.7735                              │
#> │  P-value (one-sided): 0.0000                       │
#> │  R2OS (%): 22.45                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 200                             │
#> │  Forecast horizon (h): 1                           │
#> │  Newey-West lags: 0                                │
#> │  Reference distribution: N(0,1)                    │
#> ╰────────────────────────────────────────────────────╯
#> 
```
