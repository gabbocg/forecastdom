# Unconditional Superior Predictive Ability (USPA/SPA) Test

Tests the null hypothesis that a benchmark forecasting method has
unconditional superior predictive ability over all competing
alternatives, using Hansen's (2005) stationary bootstrap approach.

## Usage

``` r
spa_test(Y, level, B = 5000L, q = 0.25)
```

## Arguments

- Y:

  An `n x J` matrix of loss differentials with respect to the benchmark.
  Positive values indicate the benchmark outperforms competitor `j` in
  period `t`.

- level:

  Significance level (e.g., 0.05).

- B:

  Integer; number of bootstrap replications. Default `5000`.

- q:

  Numeric in \\(0, 1)\\; parameter for the geometric distribution in the
  stationary bootstrap. Controls the average block length (\\1/q\\).
  Default `0.25` (average block length of 4).

## Value

A list with class `"spa_test"` containing:

- statistic:

  The SPA test statistic (consistent).

- pvalue:

  Bootstrap p-value.

- reject:

  Logical; whether the null is rejected.

- level:

  Significance level used.

- d_bar:

  Sample mean of loss differentials for each competitor.

- n:

  Number of observations.

- J:

  Number of competitors.

- B:

  Number of bootstrap replications.

## Details

The SPA test statistic is: \$\$T^{SPA} = \max\_{1 \le j \le J}
\frac{\sqrt{n}\\ \bar{d}\_j}{\hat{\sigma}\_j}\$\$ where \\\bar{d}\_j\\
is the mean loss differential for competitor `j` and \\\hat{\sigma}\_j\\
is its estimated standard deviation.

The null hypothesis is rejected when the benchmark is not superior to
all competitors, i.e., some competitor significantly outperforms it.

Hansen's (2005) consistent test uses a pre-selection step to remove
clearly inferior competitors from the critical value computation.

## References

Hansen, P.R. (2005). A Test for Superior Predictive Ability. *Journal of
Business & Economic Statistics*, 23(4), 365-380.

White, H. (2000). A Reality Check for Data Snooping. *Econometrica*,
68(5), 1097-1126.

## Examples

``` r
# \donttest{
sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
spa_test(sim$Y, level = 0.05, B = 500)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │          Superior Predictive Ability Test          │
#> │                   (Hansen, 2005)                   │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark is superior to all competitors       │
#> │ H1: Some competitor outperforms the benchmark      │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  SPA statistic: 48.9787                            │
#> │  P-value (bootstrap): 0.0020                       │
#> │  Decision: Rejected ***                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 250                             │
#> │  Competitors (J): 3                                │
#> │  Bootstrap replications: 500                       │
#> │  Significance level: 0.0500                        │
#> ╰────────────────────────────────────────────────────╯
#> 
# }
```
