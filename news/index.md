# Changelog

## forecastdom 0.1.0

- Added
  [`mse_f_test()`](https://gabbocg.github.io/forecastdom/reference/mse_f_test.md),
  the McCracken (2007) MSE-F equal-MSFE statistic for nested
  out-of-sample forecast comparison.
- Added
  [`uspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/uspa_mh_test.md)
  and
  [`aspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/aspa_mh_test.md),
  the uniform and average multi-horizon SPA tests of Quaedvlieg (2021),
  implemented with a moving-block bootstrap.
- Bundled `cm2001`, `hl2005`, `gw2006`, `wg2008`, `quaedvlieg2021`,
  `llq2022`, `llq2022_jnj`, and `llq2022_uv_cspa` datasets used by the
  replication articles.
