# forecastdom  <a href="https://github.com/GabboCg/forecastdom"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/GabboCg/forecastdom)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Overview

**forecastdom** provides a unified toolkit for forecast dominance testing in R. It covers the full taxonomy of forecast evaluation hypotheses — unconditional and conditional, equal and superior — plus encompassing, nested-model, predictive regression, and parameter instability tests.

## Installation

```r
# install.packages("devtools")
devtools::install_github("GabboCg/forecastdom")
```

## Tests

### Forecast Comparison

| Function | Test | Reference |
|---|---|---|
| `dm_test()` | Diebold-Mariano (+ HLN correction) | Diebold & Mariano (1995); Harvey, Leybourne & Newbold (1997) |
| `cw_test()` | Clark-West MSFE-adjusted | Clark & West (2007) |
| `enc_new()` | ENC-NEW Encompassing | Clark & McCracken (2001) |
| `gw_test()` | Giacomini-White (CEPA) | Giacomini & White (2006) |
| `spa_test()` | Hansen's SPA (USPA) | Hansen (2005) |
| `cspa_test()` | Conditional Superior Predictive Ability | Li, Liao & Quaedvlieg (2022) |
| `csms()` | Confidence Set for the Most Superior | Li, Liao & Quaedvlieg (2022) |

### Predictive Regression & Parameter Instability

| Function | Test | Reference |
|---|---|---|
| `ivx_wald()` | IVX-Wald for persistent predictors | Kostakis, Magdalinos & Stamatogiannis (2015) |
| `qll_hat()` | Elliott-Muller parameter instability | Elliott & Muller (2006) |

## Usage

### Pairwise forecast comparison

```r
library(forecastdom)

# Diebold-Mariano test with HLN correction
e1 <- rnorm(200)
e2 <- rnorm(200, mean = 0.1)
dm_test(e1, e2)
```

### Conditional Superior Predictive Ability

```r
# Simulate data from LLQ (2022) DGP
sim <- do_sim(J = 3, n = 500, a = 1.5, c = 0, rho_u = 0.4)

# CSPA test
result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
result

# Visualization
cspa_test_plot(result)
```

### Confidence Set for the Most Superior

```r
# Compare multiple methods symmetrically
csms(losses, X, level = 0.05, trim = 2, method_names = c("AR1", "HAR", "HARQ", "LASSO"))
```

### IVX-Wald test for return predictability

```r
ivx_wald(returns, predictors, K = 1, M_n = floor(T ^ (1 / 3)))
```

## Taxonomy

The package covers the forecast evaluation taxonomy from Li, Liao, and Quaedvlieg (2022):

|  | **Equal** | **Superior** |
|---|---|---|
| **Unconditional** | `dm_test()` | `spa_test()` |
| **Conditional** | `gw_test()` | `cspa_test()` |

## Performance

The CSPA test uses Rcpp-accelerated C++ code for the computationally intensive operations (Gaussian process column-max and binary search p-value computation).

## References

- Clark, T.E. and McCracken, M.W. (2001). Tests of Equal Forecast Accuracy and Encompassing for Nested Models. *Journal of Econometrics*, 105(1), 85-110.
- Clark, T.E. and West, K.D. (2007). Approximately Normal Tests for Equal Predictive Accuracy in Nested Models. *Journal of Econometrics*, 138(1), 291-311.
- Diebold, F.X. and Mariano, R.S. (1995). Comparing Predictive Accuracy. *Journal of Business & Economic Statistics*, 13(3), 253-263.
- Elliott, G. and Muller, U.K. (2006). Efficient Tests for General Persistent Time Variation in Regression Coefficients. *Review of Economic Studies*, 73(4), 907-940.
- Giacomini, R. and White, H. (2006). Tests of Conditional Predictive Ability. *Econometrica*, 74(6), 1545-1578.
- Hansen, P.R. (2005). A Test for Superior Predictive Ability. *Journal of Business & Economic Statistics*, 23(4), 365-380.
- Harvey, D., Leybourne, S., and Newbold, P. (1997). Testing the Equality of Prediction Mean Squared Errors. *International Journal of Forecasting*, 13(2), 281-291.
- Kostakis, A., Magdalinos, T., and Stamatogiannis, M.P. (2015). Robust Econometric Inference for Stock Return Predictability. *Review of Financial Studies*, 28(5), 1506-1553.
- Li, J., Liao, Z., and Quaedvlieg, R. (2022). Conditional Superior Predictive Ability. *Review of Economic Studies*, 89(2), 843-875.

