# Clark-West Test for Predictive Ability of Nested Models

Tests whether an alternative (unrestricted) model has superior
out-of-sample predictive ability relative to a benchmark (restricted)
model, using the MSFE-adjusted statistic of Clark and West (2007). Also
computes the out-of-sample \\R^2\_{OS}\\ statistic.

## Usage

``` r
cw_test(e1, e2, f1, f2)
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

## Details

The MSFE-adjusted series is defined as: \$\$\hat{f}\_t = e\_{1,t}^2 -
\left(e\_{2,t}^2 - (f\_{1,t} - f\_{2,t})^2\right)\$\$ The test regresses
\\\hat{f}\_t\\ on a constant and uses the resulting t-statistic,
compared to a standard normal distribution (one-sided).

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
#> │  CW statistic: 9.7491                              │
#> │  P-value (one-sided): 0.0000                       │
#> │  R2OS (%): 22.45                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 200                             │
#> │  Reference distribution: N(0,1)                    │
#> ╰────────────────────────────────────────────────────╯
#> 
```
