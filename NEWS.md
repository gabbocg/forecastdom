# forecastdom (development version)

* `dm_test()` documents and prints `alternative` the way it tests, the
  convention of `forecast::dm.test()`: `"less"` is the alternative that
  model 2 is less accurate than model 1, `"greater"` that it is more
  accurate. The docs and printed output previously had them swapped.
* `dm_test()` divides every autocovariance of the loss differential by `n`,
  as `forecast::dm.test()` does; the lag-0 term used `n - 1`. With the
  correction its statistic and p-value now equal `forecast::dm.test()`'s.
  It stops with an error when the long-run variance estimate is not
  positive, where it returned `NaN`.
* `cw_test()` gains `h` and `nlag` and uses a Newey-West standard error, so
  overlapping multi-step forecasts no longer over-reject: on MA(4) errors at
  `h = 5` the 5% test rejected 21% of the time under the null, and now 7%.
  The default bandwidth is `0` lags for `h = 1` and `floor(1.5 * h)`
  otherwise, after Clark and West (2007). At `h = 1` the statistic is the
  previous one times `sqrt(n / (n - 1))`.
* `gw_test()` gains `h` and `nlag`. The default instruments lag the loss
  differential by `h`, the last one known at the forecast origin; lagging
  it by one at `h > 1` rejected a true null almost always. The covariance
  uses `0` Newey-West lags for `h = 1`, as Giacomini and White (2006,
  Theorem 1) allow, and `floor(1.5 * h)` otherwise; it previously used
  `floor(1.2 * n^(1/3))` lags whatever the horizon. A singular moment
  covariance stops with an error naming the collinear instruments, where
  the test fell back to a generalised inverse.
* `dm_test()`, `cw_test()` and `gw_test()` check that `h` is a positive
  integer smaller than the number of forecast errors.
* Added value tests: `dm_test()` against `forecast::dm.test()`, `cw_test()`
  and `gw_test()` against least squares with `sandwich::NeweyWest()`, and a
  Monte Carlo of the size of `cw_test()` and `gw_test()` on overlapping
  multi-step forecasts.

# forecastdom 0.1.1

* `spa_test()` now follows Hansen (2005). It previously tested in the wrong
  direction (rejecting when the benchmark was best), scaled the statistic by
  an extra `sqrt(n)`, and did not use Hansen's consistent recentring. The
  `hl2005` article is updated: GARCH(1,1) is not rejected under any
  realised-variance proxy at the 5% level.

* `cspa_test()` now reports the correct p-value when the null is rejected at
  every level (was 1, now 0) or at none (was 0, now 1). The `reject`
  decision was unaffected.
* Added tests for `cspa_test()`, `csms()`, `cspa_test_plot()`,
  `do_prewhiten()` and `get_legendre()`.

* Refined the package title and `DESCRIPTION` text per CRAN feedback:
  removed the redundant "Tools for" prefix from the title and spelled out
  acronyms (MSFE, SPA) on first use.

# forecastdom 0.1.0

Initial release. Provides a unified toolkit for out-of-sample forecast
dominance testing.

## Tests

* `dm_test()` — Diebold-Mariano (with Harvey, Leybourne, and Newbold
  (1997) small-sample correction).
* `cw_test()` — Clark and West (2007) MSFE-adjusted statistic.
* `mse_f_test()` — McCracken (2007) MSE-F equal-MSFE statistic for
  nested out-of-sample comparison.
* `enc_new()` — ENC-NEW encompassing test of Clark and McCracken (2001).
* `gw_test()` — Giacomini and White (2006) conditional equal predictive
  ability test.
* `spa_test()` — Hansen (2005) test for superior predictive ability.
* `cspa_test()` — Li, Liao, and Quaedvlieg (2022) test for conditional
  superior predictive ability, with the accompanying `cspa_test_plot()`
  visualisation and `csms()` confidence set for the most superior method.
* `uspa_mh_test()` and `aspa_mh_test()` — uniform and average
  multi-horizon SPA tests of Quaedvlieg (2021), implemented with a
  moving-block bootstrap.
* `ivx_wald()` — Kostakis, Magdalinos, and Stamatogiannis (2015) IVX-Wald
  statistic for predictive regressions with persistent regressors.
* `qll_hat()` — Elliott and Muller (2006) qLL statistic for testing
  parameter time variation.

## Data

Bundled `cm2001`, `hl2005`, `gw2006`, `wg2008`, `quaedvlieg2021`,
`llq2022`, `llq2022_jnj`, `llq2022_uv_cspa`, `nrtz2014`, `rossi2006`,
`rrz2016`, and `rz2013` datasets used by the replication vignettes.
