# Bilateral Nominal Exchange Rates (Rossi, 2006)

Monthly nominal exchange rates against the U.S. dollar for five
industrialised economies, used in the empirical exercise of Rossi
(2006). Originally distributed as a Datastream extract in the
replication archive at <https://github.com/gabbocg/rossi2006>.

## Usage

``` r
rossi2006
```

## Format

A data frame with 1,550 rows and 3 variables:

- date:

  First-of-month `Date`, from 1973-03-01 to 1998-12-01 (310 monthly
  observations per country).

- country:

  Factor with levels `"Canada"`, `"France"`, `"Germany"`, `"Italy"`,
  `"Japan"`.

- fx:

  Numeric. Nominal bilateral exchange rate level vs. the U.S. dollar, as
  supplied in the source file. The empirical exercise in Rossi (2006)
  works with `log(fx)` and its monthly differences.

## Source

Replication archive of Rossi (2006):
<https://github.com/gabbocg/rossi2006>.

## References

Rossi, B. (2006). Are exchange rates really random walks? Some evidence
robust to parameter instability. *Macroeconomic Dynamics*, 10(1), 20-38.

Meese, R. A. and Rogoff, K. (1983). Empirical exchange rate models of
the seventies: Do they fit out of sample? *Journal of International
Economics*, 14(1-2), 3-24.

## Examples

``` r
data(rossi2006)
head(rossi2006)
#>         date country    fx
#> 1 1973-03-01  Canada 100.1
#> 2 1973-04-01  Canada  99.7
#> 3 1973-05-01  Canada 100.5
#> 4 1973-06-01  Canada 100.2
#> 5 1973-07-01  Canada  99.8
#> 6 1973-08-01  Canada  99.5
with(subset(rossi2006, country == "Japan"),
     plot(date, log(fx), type = "l", main = "Japan log FX"))
```
