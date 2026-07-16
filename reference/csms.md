# Confidence Set for the Most Superior (CSMS) Forecasting Method

Constructs the confidence set for the most superior forecasting method
by inverting the CSPA test, as described in Section 2.3 of Li, Liao, and
Quaedvlieg (2022). The set contains all methods `j` for which the CSPA
null hypothesis (with `j` as benchmark) is not rejected.

## Usage

``` r
csms(
  losses,
  X,
  level,
  trim = 0,
  prewhiten = -1L,
  preselect = TRUE,
  R = 10000L,
  method_names = NULL
)
```

## Arguments

- losses:

  An `n x (J+1)` matrix where each column contains the loss series for a
  forecasting method. All methods are treated symmetrically (no
  pre-specified benchmark).

- X:

  An `n x 1` numeric vector of the conditioning variable.

- level:

  Significance level (e.g., 0.05).

- trim:

  Trimming parameter (standard deviations). Default `0`.

- prewhiten:

  Pre-whitening order. Default `-1` (AIC).

- preselect:

  Logical; adaptive inequality selection. Default `TRUE`.

- R:

  Integer; Gaussian process replications. Default `10000`.

- method_names:

  Optional character vector of method names. If `NULL`, uses
  `"M1", "M2", ...`.

## Value

A list with class `"csms"` containing:

- in_set:

  Logical vector; which methods are in the confidence set.

- set_members:

  Names of methods in the confidence set.

- theta:

  Theta values for each method as benchmark.

- pvalues:

  P-values for each method as benchmark.

- method_names:

  Names of all methods.

- level:

  Significance level.

- n_methods:

  Total number of methods.

## Details

For each method `j` in `0, ..., J`, the CSPA test is applied with `j` as
the benchmark. The confidence set is:
\$\$\widehat{\mathcal{M}}\_{n,1-\alpha} = \\0 \le j \le J : \text{CSPA
test with } j \text{ as benchmark does not reject}\\\$\$

## References

Li, J., Liao, Z., and Quaedvlieg, R. (2022). Conditional Superior
Predictive Ability. *Review of Economic Studies*, 89(2), 843-875.

## Examples

``` r
# \donttest{
set.seed(42)
n <- 300
X <- arima.sim(list(ar = 0.5), n = n, sd = sqrt(0.75))
losses <- matrix(rnorm(n * 4), n, 4)
csms(losses, X, level = 0.05, trim = 2, R = 500L)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │    Confidence Set for the Most Superior (CSMS)     │
#> │          (Li, Liao, and Quaedvlieg, 2022)          │
#> ├────────────────────────────────────────────────────┤
#> │ 95% Confidence Set: {M1, M2, M3, M4}               │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Per-method CSPA results:                           │
#> │                                                    │
#> │  Method               Theta     P-value  In Set?   │
#> │  ------------------------------------------------  │
#> │  M1                  0.1670      0.3800      Yes   │
#> │  M2                  0.0919      0.1300      Yes   │
#> │  M3                  0.0860      0.1640      Yes   │
#> │  M4                  0.1739      0.6600      Yes   │
#> ╰────────────────────────────────────────────────────╯
#> 
# }
```
