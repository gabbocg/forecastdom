# forecastdom

**Author:** [Gabriel Cabrera](https://github.com/GabboCg)  
**License:** [MIT](https://opensource.org/licenses/MIT)

## Overview

**forecastdom** is an R toolkit for comparing the predictive ability of
forecasting methods. It implements the four cells of the Li, Liao, and
Quaedvlieg (2022) taxonomy (equal vs. superior, unconditional
vs. conditional) plus tests for nested models, forecast encompassing,
return predictability, and parameter instability.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("GabboCg/forecastdom")
```

## Tests

### Forecast Comparison

| Function                                                                            | Test                                    | Reference                                                    |
|-------------------------------------------------------------------------------------|-----------------------------------------|--------------------------------------------------------------|
| [`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md)           | Diebold-Mariano (+ HLN correction)      | Diebold & Mariano (1995); Harvey, Leybourne & Newbold (1997) |
| [`cw_test()`](https://gabbocg.github.io/forecastdom/reference/cw_test.md)           | Clark-West MSFE-adjusted                | Clark & West (2007)                                          |
| [`enc_new()`](https://gabbocg.github.io/forecastdom/reference/enc_new.md)           | ENC-NEW Encompassing                    | Clark & McCracken (2001)                                     |
| [`mse_f_test()`](https://gabbocg.github.io/forecastdom/reference/mse_f_test.md)     | McCracken MSE-F equal-MSFE              | McCracken (2007)                                             |
| [`gw_test()`](https://gabbocg.github.io/forecastdom/reference/gw_test.md)           | Giacomini-White (CEPA)                  | Giacomini & White (2006)                                     |
| [`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)         | Hansen’s SPA (USPA)                     | Hansen (2005)                                                |
| [`cspa_test()`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md)       | Conditional Superior Predictive Ability | Li, Liao & Quaedvlieg (2022)                                 |
| [`uspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/uspa_mh_test.md) | Uniform Multi-Horizon SPA               | Quaedvlieg (2021)                                            |
| [`aspa_mh_test()`](https://gabbocg.github.io/forecastdom/reference/aspa_mh_test.md) | Average Multi-Horizon SPA               | Quaedvlieg (2021)                                            |
| [`csms()`](https://gabbocg.github.io/forecastdom/reference/csms.md)                 | Confidence Set for the Most Superior    | Li, Liao & Quaedvlieg (2022)                                 |

### Predictive Regression & Parameter Instability

| Function                                                                    | Test                                 | Reference                                    |
|-----------------------------------------------------------------------------|--------------------------------------|----------------------------------------------|
| [`ivx_wald()`](https://gabbocg.github.io/forecastdom/reference/ivx_wald.md) | IVX-Wald for persistent predictors   | Kostakis, Magdalinos & Stamatogiannis (2015) |
| [`qll_hat()`](https://gabbocg.github.io/forecastdom/reference/qll_hat.md)   | Elliott-Muller parameter instability | Elliott & Muller (2006)                      |

## Usage

### Pairwise forecast comparison

``` r
library(forecastdom)

# Diebold-Mariano test with HLN correction
e1 <- rnorm(200)
e2 <- rnorm(200, mean = 0.1)
dm_test(e1, e2)
```

### Conditional Superior Predictive Ability

``` r
# Simulate data from LLQ (2022) DGP
sim <- do_sim(J = 3, n = 500, a = 1.5, c = 0, rho_u = 0.4)

# CSPA test
result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
result

# Visualization
cspa_test_plot(result)
```

### Confidence Set for the Most Superior

``` r
# Compare multiple methods symmetrically
csms(losses, X, level = 0.05, trim = 2, method_names = c("AR1", "HAR", "HARQ", "LASSO"))
```

### IVX-Wald test for return predictability

``` r
ivx_wald(returns, predictors, K = 1, M_n = floor(T ^ (1 / 3)))
```

## Taxonomy

The four cells in Li, Liao, and Quaedvlieg (2022):

|                   | **Equal accuracy**                                                        | **Superior accuracy**                                                         |
|-------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| **Unconditional** | [`dm_test()`](https://gabbocg.github.io/forecastdom/reference/dm_test.md) | [`spa_test()`](https://gabbocg.github.io/forecastdom/reference/spa_test.md)   |
| **Conditional**   | [`gw_test()`](https://gabbocg.github.io/forecastdom/reference/gw_test.md) | [`cspa_test()`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md) |

Equal vs. superior asks whether forecasts have the same loss or whether
one is strictly lower. Unconditional vs. conditional asks whether the
comparison holds on average or holds at every value of a conditioning
variable.

## Performance

The CSPA test uses Rcpp / C++ for the two hot loops (Gaussian-process
column maxima and the binary search over the p-value).

## References

- Clark, T.E. and McCracken, M.W. (2001). Tests of Equal Forecast
  Accuracy and Encompassing for Nested Models. *Journal of
  Econometrics*, 105(1), 85-110.
- Clark, T.E. and West, K.D. (2007). Approximately Normal Tests for
  Equal Predictive Accuracy in Nested Models. *Journal of Econometrics*,
  138(1), 291-311.
- Diebold, F.X. and Mariano, R.S. (1995). Comparing Predictive Accuracy.
  *Journal of Business & Economic Statistics*, 13(3), 253-263.
- Elliott, G. and Muller, U.K. (2006). Efficient Tests for General
  Persistent Time Variation in Regression Coefficients. *Review of
  Economic Studies*, 73(4), 907-940.
- Giacomini, R. and White, H. (2006). Tests of Conditional Predictive
  Ability. *Econometrica*, 74(6), 1545-1578.
- Hansen, P.R. (2005). A Test for Superior Predictive Ability. *Journal
  of Business & Economic Statistics*, 23(4), 365-380.
- Harvey, D., Leybourne, S., and Newbold, P. (1997). Testing the
  Equality of Prediction Mean Squared Errors. *International Journal of
  Forecasting*, 13(2), 281-291.
- Kostakis, A., Magdalinos, T., and Stamatogiannis, M.P. (2015). Robust
  Econometric Inference for Stock Return Predictability. *Review of
  Financial Studies*, 28(5), 1506-1553.
- Li, J., Liao, Z., and Quaedvlieg, R. (2022). Conditional Superior
  Predictive Ability. *Review of Economic Studies*, 89(2), 843-875.
- McCracken, M.W. (2007). Asymptotics for Out of Sample Tests of Granger
  Causality. *Journal of Econometrics*, 140(2), 719-752.
- Quaedvlieg, R. (2021). Multi-Horizon Forecast Comparison. *Journal of
  Business & Economic Statistics*, 39(1), 40-53.
