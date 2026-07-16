# Conditional Superior Predictive Ability (CSPA) Test

Tests the null hypothesis that a benchmark forecasting method has
conditional superior predictive ability over competing alternatives,
uniformly across all conditioning states. Based on Li, Liao, and
Quaedvlieg (2022).

## Usage

``` r
cspa_test(Y, X, level, trim = 0, prewhiten = -1L, preselect = TRUE, R = 10000L)
```

## Arguments

- Y:

  An `n x J` matrix of loss differentials with respect to the benchmark.
  Positive values indicate the benchmark outperforms competitor `j` in
  period `t`.

- X:

  An `n x 1` numeric vector of the conditioning variable.

- level:

  Significance level (e.g., 0.05).

- trim:

  Trim observations where the conditioning variable exceeds this many
  standard deviations from the mean. Use `0` (default) for no trimming.

- prewhiten:

  Order of pre-whitening VAR for HAC estimation. Use `0` for standard
  Newey-West, or `-1` (default) for AIC-based lag selection.

- preselect:

  Logical; perform adaptive inequality selection? Default `TRUE`.

- R:

  Integer; number of bootstrap replications for critical value
  computation. Default `10000`.

## Value

A list with class `"cspa_test"` containing:

- theta:

  Infimum of the upper confidence bound. Negative values lead to
  rejection of the null.

- pvalue:

  P-value for the test.

- reject:

  Logical; whether the null is rejected at the given level.

- level:

  Significance level used.

- h_hat:

  Estimated conditional mean functions (`n x J` matrix).

- sigma_jx:

  Estimated standard deviations (`J x n` matrix).

- kp:

  Critical value from adaptive inequality selection.

- Vhat:

  Logical matrix indicating selected (j, x) pairs.

- X:

  Conditioning variable (after trimming).

- Y:

  Loss differentials (after trimming).

- K:

  Number of series terms used.

- prewhiten_order:

  Pre-whitening lag order actually used.

## References

Li, J., Liao, Z., and Quaedvlieg, R. (2022). Conditional Superior
Predictive Ability. *Review of Economic Studies*, 89(2), 843-875.

## Examples

``` r
# \donttest{
sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2, R = 500L)
print(result)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │      Conditional Superior Predictive Ability       │
#> │          (Li, Liao, and Quaedvlieg, 2022)          │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark weakly dominates all competitors     │
#> │     conditionally, uniformly across all states     │
#> │ H1: Some competitor outperforms the benchmark      │
#> │     in certain conditioning states                 │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  Theta: 0.3174                                     │
#> │  P-value: 0.8180                                   │
#> │  Significance level: 0.0500                        │
#> │  Decision: Not rejected                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Estimation Details:                                │
#> │  Observations (n): 240                             │
#> │  Competitors (J): 3                                │
#> │  Series terms (K): 4                               │
#> │  HAC lag order: 1 (pre-whitened)                   │
#> │  Selected (j,x) pairs: 720 / 720 (100.0%)          │
#> ╰────────────────────────────────────────────────────╯
#> 
# }
```
