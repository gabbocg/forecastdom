# Clark-McCracken ENC-NEW Encompassing Test

Tests whether the benchmark model encompasses the alternative model,
using the ENC-NEW statistic of Clark and McCracken (2001). Under the
null, the benchmark forecast encompasses the alternative (no additional
information in the alternative).

## Usage

``` r
enc_new(e1, e2)
```

## Arguments

- e1:

  Numeric vector of forecast errors from the benchmark model.

- e2:

  Numeric vector of forecast errors from the alternative model.

## Value

A list with class `"enc_new"` containing:

- statistic:

  The ENC-NEW test statistic.

- n:

  Number of observations.

## Details

The ENC-NEW statistic is: \$\$\text{ENC-NEW} = n \cdot
\frac{\bar{c}}{\text{MSFE}\_2}\$\$ where \\\bar{c} = n^{-1} \sum
(e\_{1,t}^2 - e\_{2,t} e\_{1,t})\\ and \\\text{MSFE}\_2 = n^{-1} \sum
e\_{2,t}^2\\.

Critical values are non-standard and depend on the estimation setup. See
Clark and McCracken (2001, Table 2) for asymptotic critical values.

## References

Clark, T.E. and McCracken, M.W. (2001). Tests of Equal Forecast Accuracy
and Encompassing for Nested Models. *Journal of Econometrics*, 105(1),
85-110.

## Examples

``` r
set.seed(42)
e1 <- rnorm(100)
e2 <- rnorm(100, sd = 0.9)
enc_new(e1, e2)
#> 
#> ╭────────────────────────────────────────────────────╮
#> │             ENC-NEW Encompassing Test              │
#> │            (Clark and McCracken, 2001)             │
#> ├────────────────────────────────────────────────────┤
#> │ H0: Benchmark encompasses the alternative          │
#> │ H1: Alternative adds predictive content            │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Test Results:                                      │
#> │  ENC-NEW statistic: 158.8083                       │
#> ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┤
#> │ Details:                                           │
#> │  Observations (n): 100                             │
#> │ Note: Critical values are non-standard.            │
#> │ See Clark & McCracken (2001, Table 2).             │
#> ╰────────────────────────────────────────────────────╯
#> 
```
