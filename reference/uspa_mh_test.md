# Uniform Multi-Horizon Superior Predictive Ability Test

Tests the null hypothesis that a benchmark forecasting method has
*uniform* (i.e. simultaneous, at every horizon) superior predictive
ability over a competitor in a multi-horizon setting, using Quaedvlieg's
(2021) moving-block-bootstrap implementation of the uniform SPA test
(`uSPA`).

## Usage

``` r
uspa_mh_test(loss_diff, L, B = 999L, level = 0.05)
```

## Arguments

- loss_diff:

  A `T x H` matrix of loss differentials, defined as `L_bench - L_comp`
  at each horizon `h = 1, ..., H`. Positive values indicate the
  benchmark has higher loss (i.e. is worse) than the competitor at that
  horizon.

- L:

  Integer; moving-block-bootstrap block length.

- B:

  Integer; number of bootstrap replications. Default `999`.

- level:

  Significance level (e.g. `0.05`). Default `0.05`.

## Value

A list with class `"uspa_mh_test"` containing:

- statistic:

  The uSPA test statistic \\t = \min_h \sqrt{T}\\\bar d_h /
  \sqrt{\hat\omega_h}\\.

- pvalue:

  Moving-block bootstrap p-value \\B^{-1}\sum_b \mathbf{1}\\t \<
  t_b^\*\\\\ (upper tail).

- reject:

  Logical; whether the null is rejected at `level`.

- level:

  Significance level used.

- L:

  Block length used.

- B:

  Number of bootstrap replications.

- T:

  Number of time periods.

- H:

  Number of forecast horizons.

- d_bar:

  Sample mean of loss differentials at each horizon (length `H`).

## Details

The uniform multi-horizon SPA test statistic is \$\$t^{uSPA} = \min\_{1
\le h \le H} \frac{\sqrt{T}\\ \bar d_h}{\sqrt{\hat\omega_h}},\$\$ where
\\\bar d_h\\ is the sample mean of the loss differential
`L_bench - L_comp` at horizon `h`, and \\\hat\omega_h\\ is its
Quadratic-Spectral HAC long-run variance estimate (Andrews, 1991).

Critical values are obtained from a moving-block bootstrap that
recentres the loss differentials so the null is imposed (Quaedvlieg,
2021), with the "natural variance" estimator recomputed within each
bootstrap replication. The resulting p-value is upper-tail: large
positive values of the statistic (i.e. the benchmark has higher loss
*uniformly* across horizons) lead to rejection. Equivalently, rejection
requires \\\bar d_h \> 0\\ at every horizon; the test has limited power
against alternatives where the benchmark is worse at only some horizons.

This is a port of the Matlab reference implementation accompanying
Quaedvlieg (2021); the helpers `.mbb_indices`, `.mbb_variance`, and
`.qs_lrvar` translate `Get_MBB_ID.m`, `MBB_Variance.m`, and `QS.m`
respectively.

## References

Quaedvlieg, R. (2021). Multi-Horizon Forecast Comparison. *Journal of
Business & Economic Statistics*, 39(1), 40-53.

## Examples

``` r
set.seed(1)
ld <- matrix(rnorm(200 * 4, mean = 0.3), 200, 4)
uspa_mh_test(ld, L = 3, B = 199, level = 0.10)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │           Uniform Multi-Horizon SPA Test           │
#> │                 (Quaedvlieg, 2021)                 │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark has uSPA (weakly dominates)          │
#> │ H1: Benchmark uniformly worse than competitor      │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  uSPA statistic: 2.8893                            │
#> │  P-value (MBB): 0.0000                             │
#> │  Decision: Rejected ***                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (T): 200                             │
#> │  Horizons (H): 4                                   │
#> │  Block length (L): 3                               │
#> │  Bootstrap replications: 199                       │
#> │  Significance level: 0.1000                        │
#> ╰────────────────────────────────────────────────────╯
#> 
```
