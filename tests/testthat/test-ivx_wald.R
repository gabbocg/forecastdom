test_that("ivx_wald returns the documented S3 structure", {
  set.seed(1)
  n <- 300
  x <- cumsum(rnorm(n))
  y <- 0.02 * x + rnorm(n)
  res <- ivx_wald(y, as.matrix(x))
  expect_s3_class(res, "ivx_wald")
  expect_equal(res$n, n)
  expect_equal(res$r, 1L)
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
})

test_that("ivx_wald handles multiple predictors", {
  set.seed(2)
  n <- 300
  X <- cbind(cumsum(rnorm(n)), cumsum(rnorm(n)))
  y <- 0.01 * X[, 1] - 0.02 * X[, 2] + rnorm(n)
  res <- ivx_wald(y, X)
  expect_equal(res$r, 2L)
  expect_length(res$coefficients, 2L)
})
