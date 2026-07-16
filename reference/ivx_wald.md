# IVX-Wald Test for Predictive Regressions

Computes the IVX-Wald statistic of Kostakis, Magdalinos, and
Stamatogiannis (2015) for testing predictability in a regression of
returns on persistent predictors. The IVX approach is robust to the
degree of persistence of the regressors (stationary, local-to-unity, or
unit root).

## Usage

``` r
ivx_wald(y, X, K = 1L, M_n = 0L, beta = 0.95)
```

## Arguments

- y:

  Numeric vector of length `T`; the dependent variable (e.g., returns).

- X:

  A `T x r` matrix of predictor observations.

- K:

  Integer; forecast horizon. Default `1`.

- M_n:

  Integer; bandwidth parameter for the long-run covariance estimator.
  Default `0` (no correction). Use `floor(T^(1/3))` as a rule of thumb.

- beta:

  Numeric in \\(0, 1)\\; controls the rate of the IVX instrument. Values
  close to 1 yield best performance. Default `0.95`.

## Value

A list with class `"ivx_wald"` containing:

- statistic:

  The IVX-Wald test statistic.

- pvalue:

  P-value from the chi-squared distribution.

- coefficients:

  IVX coefficient estimates.

- K:

  Forecast horizon.

- n:

  Number of observations.

- r:

  Number of predictors.

## Details

The IVX-Wald test constructs an endogenous instrument \\\tilde{Z}\_t\\
by filtering the predictor increments through a mildly integrated
process with autoregressive root \\R\_{nz} = 1 - 1/n^\beta\\. The
resulting Wald statistic is asymptotically chi-squared with `r` degrees
of freedom, regardless of the persistence of the predictors.

## References

Kostakis, A., Magdalinos, T., and Stamatogiannis, M.P. (2015). Robust
Econometric Inference for Stock Return Predictability. *Review of
Financial Studies*, 28(5), 1506-1553.

## Examples

``` r
set.seed(42)
n <- 200
x <- cumsum(rnorm(n))
y <- 0.02 * x + rnorm(n)
ivx_wald(y, as.matrix(x))
#> 
#> ╭────────────────────────────────────────────────────╮
#> │      IVX-Wald Test for Predictive Regressions      │
#> │  (Kostakis, Magdalinos, and Stamatogiannis, 2015)  │
#> ├────────────────────────────────────────────────────┤
#> │ H0: No predictability (all coefficients = 0)       │
#> │ H1: At least one predictor is significant          │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  IVX-Wald statistic: 1.4730                        │
#> │  P-value: 0.2249                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (T): 200                             │
#> │  Predictors (r): 1                                 │
#> │  Forecast horizon (K): 1                           │
#> │  Reference distribution: Chi-sq(1)                 │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ IVX Coefficients:                                  │
#> │    beta_1: 0.0181                                  │
#> ╰────────────────────────────────────────────────────╯
#> 
```
