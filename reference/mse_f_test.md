# McCracken MSE-F Test for Equal Forecast Accuracy

Tests the null hypothesis of equal mean squared forecast error between
the (restricted) benchmark and the (unrestricted) alternative nested
model, using the MSE-F statistic of McCracken (2007). Under the null,
the alternative does not reduce MSFE relative to the benchmark.

## Usage

``` r
mse_f_test(e1, e2, h = 1L)
```

## Arguments

- e1:

  Numeric vector of forecast errors from the benchmark (restricted)
  model.

- e2:

  Numeric vector of forecast errors from the alternative (unrestricted)
  model.

- h:

  Integer; forecast horizon. Default `1`.

## Value

A list with class `"mse_f_test"` containing:

- statistic:

  The MSE-F test statistic.

- msfe1:

  Mean squared forecast error of the benchmark.

- msfe2:

  Mean squared forecast error of the alternative.

- n:

  Number of out-of-sample observations.

- h:

  Forecast horizon.

## Details

The MSE-F statistic is: \$\$\text{MSE-F} = (T - h + 1) \cdot
\frac{\text{MSFE}\_1 - \text{MSFE}\_2}{\text{MSFE}\_2}\$\$ where \\T\\
is the number of out-of-sample observations and \\h\\ is the forecast
horizon.

Critical values are non-standard and depend on the number of extra
regressors in the alternative model (\\k_2\\) and on \\\pi = P/R\\
(out-of-sample size relative to estimation window). See McCracken (2007,
Table 1) for asymptotic critical values.

## References

McCracken, M.W. (2007). Asymptotics for out of sample tests of Granger
causality. *Journal of Econometrics*, 140(2), 719-752.

Clark, T.E. and McCracken, M.W. (2001). Tests of Equal Forecast Accuracy
and Encompassing for Nested Models. *Journal of Econometrics*, 105(1),
85-110.

## Examples

``` r
set.seed(42)
e1 <- rnorm(100)
e2 <- rnorm(100, sd = 0.9)
mse_f_test(e1, e2)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │       MSE-F Test for Equal Forecast Accuracy       │
#> │                 (McCracken, 2007)                  │
#> ├────────────────────────────────────────────────────┤
#> │ H0: MSFE benchmark <= MSFE alternative             │
#> │ H1: Alternative reduces MSFE                       │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  MSE-F statistic: 62.3868                          │
#> │  MSFE benchmark: 1.0746                            │
#> │  MSFE alternative: 0.6618                          │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 100                             │
#> │  Forecast horizon (h): 1                           │
#> │ Note: Critical values are non-standard.            │
#> │ See McCracken (2007, Table 1).                     │
#> ╰────────────────────────────────────────────────────╯
#> 
```
