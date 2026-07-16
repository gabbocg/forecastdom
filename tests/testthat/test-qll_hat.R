test_that("qll_hat returns the documented S3 structure", {
  set.seed(1)
  n <- 250
  x <- matrix(rnorm(n * 2), n, 2)
  y <- x %*% c(0.5, -0.3) + rnorm(n)
  res <- qll_hat(y, x)
  expect_s3_class(res, "qll_hat")
  expect_equal(res$n, n)
  expect_equal(res$k, 2L)
})

test_that("qll_hat accepts fixed-coefficient covariates via Z", {
  set.seed(2)
  n <- 250
  x <- matrix(rnorm(n), n, 1)
  z <- matrix(rnorm(n), n, 1)
  y <- 0.4 * x + 0.2 * z + rnorm(n)
  res <- qll_hat(y, x, Z = z, L = 2L)
  expect_s3_class(res, "qll_hat")
  expect_equal(res$k, 1L)
})
