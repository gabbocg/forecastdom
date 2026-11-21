# Conditional Equal Predictive Ability (CEPA) Test

Tests the null hypothesis of conditional equal predictive ability using
the Giacomini and White (2006) approach. The test checks whether loss
differentials are conditionally mean-zero given an information set,
using a finite set of instruments.

## Usage

``` r
gw_test(e1, e2, instruments = NULL, loss = c("SE", "AE"), h = 1L, nlag = NULL)
```

## Arguments

- e1:

  Numeric vector of forecast errors from model 1 (benchmark).

- e2:

  Numeric vector of forecast errors from model 2 (competitor).

- instruments:

  An `n x q` matrix of instruments (conditioning variables). Row \\t\\
  pairs with the loss differential \\d_t\\ and must be known at that
  forecast's origin, \\h\\ periods before \\d_t\\ is observed. Column
  names, if any, label the instruments in error messages. If `NULL`
  (default), uses a constant and the loss differential lagged by `h`.

- loss:

  Character; loss function. `"SE"` for squared error (default), `"AE"`
  for absolute error.

- h:

  Integer; forecast horizon. Default `1`.

- nlag:

  Non-negative integer; number of Newey-West lags. If `NULL` (default),
  uses `0` for `h = 1` and `floor(1.5 * h)` otherwise.

## Value

A list with class `"gw_test"` containing:

- statistic:

  The Wald test statistic.

- pvalue:

  P-value from the chi-squared distribution.

- df:

  Degrees of freedom (number of instruments).

- n:

  Number of observations used.

- loss:

  Loss function used.

- h:

  Forecast horizon.

- nlag:

  Number of Newey-West lags used.

## Details

The test is based on the unconditional moment conditions implied by the
CEPA null hypothesis: \$\$E\[d_t \cdot W_t\] = 0\$\$ where \\d_t\\ is
the loss differential and \\W_t\\ is a vector of instruments measurable
with respect to the conditioning information set.

The test statistic follows a chi-squared distribution with \\q\\ degrees
of freedom, where \\q\\ is the number of instruments.

The covariance of \\d_t W_t\\ is Newey-West (Bartlett weights, demeaned,
autocovariances divided by \\n\\) with `nlag` lags. For `h = 1` the
moments are a martingale difference under the null and the sample
covariance suffices (Giacomini and White, 2006, Theorem 1). For `h > 1`
they are serially correlated up to lag \\h - 1\\. Giacomini and White's
code uses \\h - 1\\ lags, but Bartlett weights then shrink those
autocovariances and the test over-rejects, so the default is the
\\1.5h\\ bandwidth of Clark and West (2007); `nlag = h - 1` reproduces
their code's choice.

If the moment covariance is singular, the test stops and names the
instruments whose moments are collinear.

## References

Giacomini, R. and White, H. (2006). Tests of Conditional Predictive
Ability. *Econometrica*, 74(6), 1545-1578.

Clark, T.E. and West, K.D. (2007). Approximately Normal Tests for Equal
Predictive Accuracy in Nested Models. *Journal of Econometrics*, 138(1),
291-311.

## Examples

``` r
set.seed(42)
e1 <- rnorm(200)
e2 <- rnorm(200, sd = 0.9)
gw_test(e1, e2)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │     Conditional Equal Predictive Ability Test      │
#> │            (Giacomini and White, 2006)             │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Equal conditional predictive ability           │
#> │ H1: Methods differ conditionally                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  Wald statistic: 4.6835                            │
#> │  P-value: 0.0962                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 199                             │
#> │  Instruments (q): 2                                │
#> │  Forecast horizon (h): 1                           │
#> │  Newey-West lags: 0                                │
#> │  Loss function: SE                                 │
#> │  Reference distribution: Chi-sq(2)                 │
#> ╰────────────────────────────────────────────────────╯
#> 
```
