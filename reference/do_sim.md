# Simulate Data from the CSPA Paper DGP

Generates data from the data generating process in Section 3.1 of Li,
Liao, and Quaedvlieg (2022). The conditioning variable \\X_t\\ follows a
Gaussian AR(1) with coefficient 0.5, and the loss differentials are
\\Y\_{j,t} = 1 - a \exp(-(X_t - c)^2) + u\_{j,t}\\, where \\u\_{j,t}\\
follows an AR(1) with coefficient `rho_u`.

## Usage

``` r
do_sim(J, n, a, c, rho_u)
```

## Arguments

- J:

  Integer; number of competing forecast methods.

- n:

  Integer; sample size.

- a:

  Numeric; controls the shape of the conditional mean function. `a = 1`
  gives the null hypothesis (\\h_j(c) = 0\\).

- c:

  Numeric; location parameter for the minimum of \\h_j(x)\\.

- rho_u:

  Numeric in \\\[0, 1)\\; AR(1) coefficient of the error process. Higher
  values induce more serial dependence.

## Value

A list with components:

- Y:

  An `n x J` matrix of loss differentials.

- X:

  A numeric vector of length `n`.

## Examples

``` r
sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
str(sim)
#> List of 2
#>  $ Y: num [1:250, 1:3] -1.763 -1.506 -0.567 -2.614 0.294 ...
#>  $ X: num [1:250] -1.446 1.041 0.614 0.234 0.546 ...
```
