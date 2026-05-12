# Pairwise CSPA Rejection Counts Across 28 Stocks

Pre-computed rejection counts replicating Table_UV_CSPA.xlsx from the
Li, Liao and Quaedvlieg (2022) replication package. For each of 28
stocks, pairwise conditional superior predictive ability (CSPA) tests
are run for every benchmark-competitor pair across six realized-variance
forecasting models; cell \\(k, l)\\ counts the number of stocks for
which the null “benchmark \\l\\ conditionally dominates alternative
\\k\\” is rejected at the 5% level. Conditioning variable is
one-day-lagged VIX; loss is QLIKE.

## Usage

``` r
llq2022_uv_cspa
```

## Format

A list with the following components:

- mine:

  \\6 \times 6\\ integer matrix of rejection counts produced by
  [`forecastdom::cspa_test`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md)
  with `R = 10000` bootstrap reps and AIC pre-whitening, matching the
  call signature in `Empirics_Volatility.ox`.

- paper:

  \\6 \times 6\\ integer matrix from `Table_UV_CSPA.xlsx` in the LLQ
  replication package.

- losses:

  \\28 \times 6\\ matrix of mean QLIKE loss per stock and model.

- tickers:

  Character vector of the 28 tickers used.

- models:

  Character vector of the six model names.

- level:

  Significance level used (0.05).

- R:

  Number of bootstrap replications used.

## Source

Computed by `data-raw/llq2022_uv_cspa.R` from the replication package of
Li, Liao and Quaedvlieg (2022), <https://zenodo.org/record/4884813>.

## References

Li, J., Liao, Z. and Quaedvlieg, R. (2022). Conditional Superior
Predictive Ability. *Review of Economic Studies*, 89(2), 843-875.
