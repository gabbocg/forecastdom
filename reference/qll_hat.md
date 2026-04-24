# Elliott-Muller Test for Time-Varying Coefficients

Computes the \\\hat{qLL}\\ statistic of Elliott and Muller (2006) for
testing the null hypothesis that regression coefficients are constant
over time against the alternative of general time variation.

## Usage

``` r
qll_hat(y, X, Z = NULL, L = 0L)
```

## Arguments

- y:

  Numeric vector of length `T`; the dependent variable.

- X:

  A `T x k` matrix of regressors linked to potentially time-varying
  coefficients.

- Z:

  A `T x d` matrix of regressors with constant coefficients. Use `NULL`
  (default) if all coefficients may vary.

- L:

  Integer; lag truncation for the Newey-West estimator of the variance.
  Default `0` (no correction).

## Value

A list with class `"qll_hat"` containing:

- statistic:

  The \\\hat{qLL}\\ test statistic.

- k:

  Number of potentially time-varying coefficients.

- n:

  Number of observations.

## Details

The test is based on optimal invariant statistics for the null of
constant coefficients against local alternatives. The \\\hat{qLL}\\
statistic has non-standard critical values that depend on `k`; see Table
1 in Elliott and Muller (2006).

Selected critical values (5\\

- `k = 1`: -5.91

- `k = 2`: -10.64

- `k = 3`: -15.78

- `k = 4`: -20.62

- `k = 5`: -25.87

Reject the null when \\\hat{qLL}\\ is below the critical value.

## References

Elliott, G. and Muller, U.K. (2006). Efficient Tests for General
Persistent Time Variation in Regression Coefficients. *Review of
Economic Studies*, 73(4), 907-940.

## Examples

``` r
if (FALSE) { # \dontrun{
set.seed(42)
n <- 200
x <- matrix(rnorm(n * 2), n, 2)
y <- x %*% c(0.5, -0.3) + rnorm(n)
qll_hat(y, x)
} # }
```
