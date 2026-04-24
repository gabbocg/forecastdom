# Newey-West Long-Run Covariance Estimator

Estimates the long-run covariance matrix using Newey-West (Bartlett)
weights.

## Usage

``` r
covnw(data, nlag = NULL, demean = TRUE)
```

## Arguments

- data:

  A `T x K` numeric matrix.

- nlag:

  Non-negative integer lag length. If `NULL` (default), uses
  `floor(1.2 * T^(1/3))`.

- demean:

  Logical; subtract column means before estimation? Default `TRUE`.

## Value

A `K x K` covariance matrix.
