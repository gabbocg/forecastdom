# Package index

## Forecast Comparison Tests

Pairwise and multivariate tests for comparing the predictive ability of
forecasting methods.

- [`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md)
  : Diebold-Mariano Test for Equal Predictive Ability
- [`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)
  : Clark-West Test for Predictive Ability of Nested Models
- [`enc_new()`](https://gabbocg.github.io/forecastdom/reference/enc_new.md)
  : Clark-McCracken ENC-NEW Encompassing Test
- [`gw_test()`](https://gabbocg.github.io/forecastdom/reference/gw_test.md)
  : Conditional Equal Predictive Ability (CEPA) Test

## Superior Predictive Ability

Tests for whether a benchmark method dominates all competitors,
unconditionally or conditionally.

- [`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)
  : Unconditional Superior Predictive Ability (USPA/SPA) Test
- [`cspa_test()`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md)
  : Conditional Superior Predictive Ability (CSPA) Test
- [`csms()`](https://gabbocg.github.io/forecastdom/reference/csms.md) :
  Confidence Set for the Most Superior (CSMS) Forecasting Method

## Predictive Regression & Instability

Tests for predictability with persistent regressors and parameter
instability.

- [`ivx_wald()`](https://gabbocg.github.io/forecastdom/reference/ivx_wald.md)
  : IVX-Wald Test for Predictive Regressions
- [`qll_hat()`](https://gabbocg.github.io/forecastdom/reference/qll_hat.md)
  : Elliott-Muller Test for Time-Varying Coefficients

## Visualization

Plotting tools for CSPA test results.

- [`cspa_test_plot()`](https://gabbocg.github.io/forecastdom/reference/cspa_test_plot.md)
  : Plot CSPA Test Results

## Simulation

Data generating process from Li, Liao, and Quaedvlieg (2022).

- [`do_sim()`](https://gabbocg.github.io/forecastdom/reference/do_sim.md)
  : Simulate Data from the CSPA Paper DGP

## Print & Summary Methods

- [`print(`*`<cspa_test>`*`)`](https://gabbocg.github.io/forecastdom/reference/print.cspa_test.md)
  : Print Method for CSPA Test Results
- [`summary(`*`<cspa_test>`*`)`](https://gabbocg.github.io/forecastdom/reference/summary.cspa_test.md)
  : Summary Method for CSPA Test Results
