# Changelog

## forecastdom 0.1.0

Initial release. Provides a unified toolkit for out-of-sample forecast
dominance testing.

### Tests

- [`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md)
  — Diebold-Mariano (with Harvey, Leybourne, and Newbold
  1997. small-sample correction).
- [`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)
  — Clark and West (2007) MSFE-adjusted statistic.
- [`mse_f_test()`](https://gabbocg.github.io/forecastdom/reference/mse_f_test.md)
  — McCracken (2007) MSE-F equal-MSFE statistic for nested out-of-sample
  comparison.
- [`enc_new()`](https://gabbocg.github.io/forecastdom/reference/enc_new.md)
  — ENC-NEW encompassing test of Clark and McCracken (2001).
- [`gw_test()`](https://gabbocg.github.io/forecastdom/reference/gw_test.md)
  — Giacomini and White (2006) conditional equal predictive ability
  test.
- [`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)
  — Hansen (2005) test for superior predictive ability.
- [`cspa_test()`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md)
  — Li, Liao, and Quaedvlieg (2022) test for conditional superior
  predictive ability, with the accompanying
  [`cspa_test_plot()`](https://gabbocg.github.io/forecastdom/reference/cspa_test_plot.md)
  visualisation and
  [`csms()`](https://gabbocg.github.io/forecastdom/reference/csms.md)
  confidence set for the most superior method.
- [`uspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/uspa_mh_test.md)
  and
  [`aspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/aspa_mh_test.md)
  — uniform and average multi-horizon SPA tests of Quaedvlieg (2021),
  implemented with a moving-block bootstrap.
- [`ivx_wald()`](https://gabbocg.github.io/forecastdom/reference/ivx_wald.md)
  — Kostakis, Magdalinos, and Stamatogiannis (2015) IVX-Wald statistic
  for predictive regressions with persistent regressors.
- [`qll_hat()`](https://gabbocg.github.io/forecastdom/reference/qll_hat.md)
  — Elliott and Muller (2006) qLL statistic for testing parameter time
  variation.

### Data

Bundled `cm2001`, `hl2005`, `gw2006`, `wg2008`, `quaedvlieg2021`,
`llq2022`, `llq2022_jnj`, `llq2022_uv_cspa`, `nrtz2014`, `rossi2006`,
`rrz2016`, and `rz2013` datasets used by the replication vignettes.
