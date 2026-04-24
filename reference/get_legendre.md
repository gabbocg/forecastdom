# Compute Legendre Polynomial Basis Matrix

Evaluates Legendre polynomials up to order `K` at the points in `x`.
Used internally for series estimation in the CSPA test.

## Usage

``` r
get_legendre(x, K)
```

## Arguments

- x:

  Numeric vector of evaluation points, typically in \\\[-1, 1\]\\.

- K:

  Integer, number of basis functions (columns) to return.

## Value

An `n x K` matrix where column `k` contains the `(k-1)`-th Legendre
polynomial evaluated at `x`.
