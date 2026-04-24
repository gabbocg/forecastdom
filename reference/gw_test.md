# Conditional Equal Predictive Ability (CEPA) Test

Tests the null hypothesis of conditional equal predictive ability using
the Giacomini and White (2006) approach. The test checks whether loss
differentials are conditionally mean-zero given an information set,
using a finite set of instruments.

## Usage

``` r
gw_test(e1, e2, instruments = NULL, loss = c("SE", "AE"))
```

## Arguments

- e1:

  Numeric vector of forecast errors from model 1 (benchmark).

- e2:

  Numeric vector of forecast errors from model 2 (competitor).

- instruments:

  An `n x q` matrix of instruments (conditioning variables) observed at
  the time of the forecast. If `NULL` (default), uses a constant and the
  lagged loss differential.

- loss:

  Character; loss function. `"SE"` for squared error (default), `"AE"`
  for absolute error.

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

## Details

The test is based on the unconditional moment conditions implied by the
CEPA null hypothesis: \$\$E\[d_t \cdot W_t\] = 0\$\$ where \\d_t\\ is
the loss differential and \\W_t\\ is a vector of instruments measurable
with respect to the conditioning information set.

The test statistic follows a chi-squared distribution with \\q\\ degrees
of freedom, where \\q\\ is the number of instruments.

## References

Giacomini, R. and White, H. (2006). Tests of Conditional Predictive
Ability. *Econometrica*, 74(6), 1545-1578.

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
#> │  Wald statistic: 3.6214                            │
#> │  P-value: 0.1635                                   │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 199                             │
#> │  Instruments (q): 2                                │
#> │  Loss function: SE                                 │
#> │  Reference distribution: Chi-sq(2)                 │
#> ╰────────────────────────────────────────────────────╯
#> 
```
