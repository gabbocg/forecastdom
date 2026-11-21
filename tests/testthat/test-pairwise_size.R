# Size under the null for overlapping h-step forecasts: h = 5, n = 1000,
# MA(h - 1) forecast errors, models of equal accuracy. A test whose
# standard error ignores the overlap rejects far more often than 5%.

size_h <- 5
size_n <- 1000
size_reps <- 2000

ma_target <- function(n, h) {
  eps <- rnorm(n + h - 1)
  as.numeric(stats::filter(eps, rep(1, h), sides = 1))[h:(n + h - 1)]
}

test_that("cw_test holds its 5% size on overlapping h-step forecasts", {
  skip_on_cran()
  set.seed(20261121)
  reject <- replicate(size_reps, {
    y <- ma_target(size_n, size_h)
    # The alternative adds a persistent predictor that is irrelevant for
    # y, so the population MSFE-adjusted differential has mean zero.
    x <- as.numeric(stats::arima.sim(list(ar = 0.9), size_n))
    f1 <- rep(0, size_n)
    f2 <- 0.1 * x
    cw_test(y - f1, y - f2, f1, f2, h = size_h)$pvalue < 0.05
  })
  expect_gte(mean(reject), 0.03)
  expect_lte(mean(reject), 0.08)
})

test_that("gw_test holds its 5% size on overlapping h-step forecasts", {
  skip_on_cran()
  set.seed(20261122)
  reject <- replicate(size_reps, {
    # Independent, identically distributed MA(h - 1) errors: the loss
    # differential has conditional mean zero given the forecast origin.
    e1 <- ma_target(size_n, size_h)
    e2 <- ma_target(size_n, size_h)
    gw_test(e1, e2, h = size_h)$pvalue < 0.05
  })
  expect_gte(mean(reject), 0.03)
  expect_lte(mean(reject), 0.08)
})
