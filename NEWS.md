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
