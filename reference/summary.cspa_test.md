# Summary Method for CSPA Test Results

Provides a detailed summary of the CSPA test, including per-competitor
diagnostics of the estimated conditional mean functions.

## Usage

``` r
# S3 method for class 'cspa_test'
summary(object, digits = 4, ...)
```

## Arguments

- object:

  An object of class `"cspa_test"`, as returned by
  [`cspa_test`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md).

- digits:

  Integer; number of decimal places. Default `4`.

- ...:

  Additional arguments (currently ignored).

## Value

Invisibly returns `object`.

## Examples

``` r
# \donttest{
sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2, R = 500L)
summary(result)
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
#> │  Theta: 0.3200                                     │
#> │  P-value: 0.9220                                   │
#> │  Significance level: 0.0500                        │
#> │  Decision: Not rejected                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Estimation Details:                                │
#> │  Observations (n): 238                             │
#> │  Competitors (J): 3                                │
#> │  Series terms (K): 4                               │
#> │  HAC lag order: 0 (Newey-West)                     │
#> │  Selected (j,x) pairs: 714 / 714 (100.0%)          │
#> ╰────────────────────────────────────────────────────╯
#> 
#> Per-competitor diagnostics:
#> 
#>   Competitor      min h_j    max h_j   mean h_j Selected % 
#>   --------------------------------------------------------
#>   j = 1           -0.1593     1.1349     0.2330     100.0%
#>   j = 2            0.0019     1.5655     0.3117     100.0%
#>   j = 3           -0.0114     2.1822     0.5327     100.0%
#> 
# }
```
