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
if (FALSE) { # \dontrun{
sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
print(result)
} # }
```
