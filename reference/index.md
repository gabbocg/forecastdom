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
unconditionally, conditionally, or jointly across forecast horizons.

- [`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)
  : Unconditional Superior Predictive Ability (USPA/SPA) Test
- [`cspa_test()`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md)
  : Conditional Superior Predictive Ability (CSPA) Test
- [`csms()`](https://gabbocg.github.io/forecastdom/reference/csms.md) :
  Confidence Set for the Most Superior (CSMS) Forecasting Method
- [`uspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/uspa_mh_test.md)
  : Uniform Multi-Horizon Superior Predictive Ability Test
- [`aspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/aspa_mh_test.md)
  : Average Multi-Horizon Superior Predictive Ability Test

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

## Datasets

Datasets bundled with the package.

- [`rossi2006`](https://gabbocg.github.io/forecastdom/reference/rossi2006.md)
  : Bilateral Nominal Exchange Rates (Rossi, 2006)
- [`rz2013`](https://gabbocg.github.io/forecastdom/reference/rz2013.md)
  : Equity Premium and Macro Predictors (Rapach & Zhou, 2013)
- [`nrtz2014`](https://gabbocg.github.io/forecastdom/reference/nrtz2014.md)
  : Equity Premium and Technical Indicators (Neely, Rapach, Tu, & Zhou,
  2014)
- [`rrz2016`](https://gabbocg.github.io/forecastdom/reference/rrz2016.md)
  : Equity Premium and Short Interest Index (Rapach, Ringgenberg & Zhou,
  2016)
- [`hl2005`](https://gabbocg.github.io/forecastdom/reference/hl2005.md)
  : IBM Volatility Forecasts and Realized-Variance Proxies (Hansen &
  Lunde, 2005)
- [`gw2006`](https://gabbocg.github.io/forecastdom/reference/gw2006.md)
  : SPF Mean CPI Inflation Forecasts (Giacomini & White, 2006 setup)
- [`quaedvlieg2021`](https://gabbocg.github.io/forecastdom/reference/quaedvlieg2021.md)
  : Loss-Differential Path Forecasts from Quaedvlieg (2021)
- [`llq2022`](https://gabbocg.github.io/forecastdom/reference/llq2022.md)
  : S&P 500 Realized-Variance Forecasts (Li, Liao & Quaedvlieg, 2022)
- [`llq2022_jnj`](https://gabbocg.github.io/forecastdom/reference/llq2022_jnj.md)
  : Johnson & Johnson Realized-Variance Forecasts (Li, Liao &
  Quaedvlieg, 2022)
- [`llq2022_uv_cspa`](https://gabbocg.github.io/forecastdom/reference/llq2022_uv_cspa.md)
  : Pairwise CSPA Rejection Counts Across 28 Stocks
