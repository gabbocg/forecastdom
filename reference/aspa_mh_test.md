# Average Multi-Horizon Superior Predictive Ability Test

Implements the average multi-horizon SPA test of Quaedvlieg (2021),
which tests whether a weighted average of horizon-wise expected loss
differentials favours the benchmark, allowing inferior performance at
some horizons to be compensated by superior performance at others.
Bootstrap follows Algorithm 1 (moving-block bootstrap, block length
`L`).

## Usage

``` r
aspa_mh_test(loss_diff, weights, L, B = 999L, level = 0.05)
```

## Arguments

- loss_diff:

  A `T x H` matrix of loss differentials, defined as `L_bench - L_comp`
  at each horizon. Positive values indicate the benchmark has higher
  loss (i.e. is worse) than the competitor.

- weights:

  Numeric vector of length `H` of horizon weights. They need not sum to
  1; uniform weights `rep(1/H, H)` reproduce the unweighted average SPA
  of the original paper.

- L:

  Integer block length for the moving-block bootstrap.

- B:

  Integer number of bootstrap replications. Default `999`.

- level:

  Significance level. Default `0.05`.

## Value

A list with class `"aspa_mh_test"` containing `statistic`, `pvalue`,
`reject`, `level`, `L`, `B`, `T`, `H`, `weights`, `d_bar`.

## Details

The aSPA statistic is \$\$t^{aSPA} = \sqrt{T}\\ \bar d^w /
\sqrt{\hat\omega^{QS}(\bar d^w)},\$\$ where \\d^w_t = \sum_h w_h
d\_{h,t}\\ and \\\hat\omega^{QS}\\ is the Quadratic-Spectral HAC
long-run variance (Andrews, 1991). Critical values are obtained via a
moving-block bootstrap that recentres the weighted series under the
null. The p-value is upper-tail (`mean(t < t_b)`); rejection requires
the weighted-average differential to be large and positive (the
benchmark loses on the weighted average).

This is a port of the Matlab reference implementation accompanying
Quaedvlieg (2021); the helpers `.mbb_indices`, `.mbb_variance`, and
`.qs_lrvar` translate `Get_MBB_ID.m`, `MBB_Variance.m`, and `QS.m`
respectively.

## References

Quaedvlieg, R. (2021). Multi-Horizon Forecast Comparison. *Journal of
Business & Economic Statistics*, 39(1), 40-53.

## See also

[`uspa_mh_test`](https://gabbocg.github.io/forecastdom/reference/uspa_mh_test.md),
[`spa_test`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)

## Examples

``` r
set.seed(2)
ld <- matrix(rnorm(200 * 4, mean = 0.2), 200, 4)
aspa_mh_test(ld, weights = rep(0.25, 4), L = 3, B = 199)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │           Average Multi-Horizon SPA Test           │
#> │                 (Quaedvlieg, 2021)                 │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark has aSPA (weighted avg superior)     │
#> │ H1: Benchmark worse on weighted average            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  aSPA statistic: 7.7808                            │
#> │  P-value (MBB): 0.0000                             │
#> │  Decision: Rejected ***                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (T): 200                             │
#> │  Horizons (H): 4                                   │
#> │  Block length (L): 3                               │
#> │  Bootstrap replications: 199                       │
#> │  Significance level: 0.0500                        │
#> ╰────────────────────────────────────────────────────╯
#> 
```
