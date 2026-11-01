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

Let \\d\_{j,t} = -Y\_{j,t}\\, so that positive values mean competitor
`j` beats the benchmark. The SPA test statistic is: \$\$T^{SPA} =
\max\left(\max\_{1 \le j \le J} \frac{\sqrt{n}\\
\bar{d}\_j}{\hat{\omega}\_j}, 0\right)\$\$ where \\\bar{d}\_j\\ is the
sample mean of \\d\_{j,t}\\ and \\\hat{\omega}\_j^2\\ is its Newey-West
long-run variance.

The null hypothesis is rejected when the benchmark is not superior to
all competitors, i.e., some competitor significantly outperforms it.

The bootstrap distribution uses Hansen's (2005) consistent recentring:
competitors with \\\sqrt{n}\\ \bar{d}\_j / \hat{\omega}\_j \< -\sqrt{2
\log \log n}\\ are treated as clearly inferior and recentred at zero
instead of \\\bar{d}\_j\\, so they do not inflate the critical value.

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
#> │  SPA statistic: 0.0000                             │
#> │  P-value (bootstrap): 1.0000                       │
#> │  Decision: Not rejected                            │
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
