# Print Method for CSPA Test Results

Displays a formatted summary of the CSPA test output, including the test
statistic (theta), p-value, decision, and key estimation details.

## Usage

``` r
# S3 method for class 'cspa_test'
print(x, digits = 4, ...)
```

## Arguments

- x:

  An object of class `"cspa_test"`, as returned by
  [`cspa_test`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md).

- digits:

  Integer; number of decimal places for numeric output. Default `4`.

- ...:

  Additional arguments (currently ignored).

## Value

Invisibly returns `x`.

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
#> │  Theta: 0.3636                                     │
#> │  P-value: 0.9240                                   │
#> │  Significance level: 0.0500                        │
#> │  Decision: Not rejected                            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Estimation Details:                                │
#> │  Observations (n): 244                             │
#> │  Competitors (J): 3                                │
#> │  Series terms (K): 4                               │
#> │  HAC lag order: 1 (pre-whitened)                   │
#> │  Selected (j,x) pairs: 732 / 732 (100.0%)          │
#> ╰────────────────────────────────────────────────────╯
#> 
# }
```
