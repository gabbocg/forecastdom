# Pre-Whiten a Multivariate Time Series

Fits a VAR model to pre-whiten the data for HAC estimation. The lag
order can be selected automatically via AIC.

## Usage

``` r
do_prewhiten(V, lag = -1L)
```

## Arguments

- V:

  A `T x K` numeric matrix.

- lag:

  Integer lag order. Use `-1` (default) for AIC-based selection (up to 4
  lags).

## Value

A list with components:

- resid:

  Residual matrix after pre-whitening.

- Phi:

  Estimated VAR coefficient matrix (stacked by lag).

- pstar:

  Selected lag order.
