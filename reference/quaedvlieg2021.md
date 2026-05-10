# Loss-Differential Path Forecasts from Quaedvlieg (2021)

Two example matrices of loss differentials at horizons \\h = 1, \dots,
20\\ from the replication archive of Quaedvlieg (2021). `$uspa` is a
configuration where average SPA holds but uniform SPA does not; `$aspa`
is a configuration where both hold.

## Usage

``` r
quaedvlieg2021
```

## Format

A list with two elements, each a `T x 20` numeric matrix:

- uspa:

  Loss differentials with aSPA but not uSPA.

- aspa:

  Loss differentials with both aSPA and uSPA.

## Source

Author's replication archive distributed alongside Quaedvlieg (2021),
*JBES* 39(1):40-53.
