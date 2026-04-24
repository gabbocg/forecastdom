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
if (FALSE) { # \dontrun{
sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
summary(result)
} # }
```
