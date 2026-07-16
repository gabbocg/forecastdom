test_that("dm_test returns the documented S3 structure", {
  set.seed(1)
  e1 <- rnorm(200)
  e2 <- rnorm(200)
  res <- dm_test(e1, e2)
  expect_s3_class(res, "dm_test")
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
})

test_that("dm_test rejects when competitor is clearly worse", {
  set.seed(2)
  n <- 500
  e1 <- rnorm(n, sd = 0.5)
  e2 <- rnorm(n, sd = 1.5)
  res <- dm_test(e1, e2, alternative = "less")
  expect_lt(res$pvalue, 0.01)
})

test_that("dm_test AE loss and HLN correction run", {
  set.seed(3)
  e1 <- rnorm(150)
  e2 <- rnorm(150)
  expect_s3_class(dm_test(e1, e2, loss = "AE"), "dm_test")
  expect_s3_class(dm_test(e1, e2, correction = TRUE, h = 4), "dm_test")
})

test_that("cw_test returns the documented S3 structure", {
  set.seed(4)
  n <- 200
  x <- rnorm(n)
  f1 <- rep(0, n)
  f2 <- 0.3 * x
  y <- 0.3 * x + rnorm(n)
  res <- cw_test(y - f1, y - f2, f1, f2)
  expect_s3_class(res, "cw_test")
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
})

test_that("mse_f_test returns the documented S3 structure", {
  set.seed(5)
  n <- 200
  e1 <- rnorm(n, sd = 1.2)
  e2 <- rnorm(n, sd = 1.0)
  res <- mse_f_test(e1, e2)
  expect_s3_class(res, "mse_f_test")
  expect_true(is.numeric(res$statistic))
})

test_that("enc_new returns the documented S3 structure", {
  set.seed(6)
  n <- 200
  e1 <- rnorm(n)
  e2 <- rnorm(n)
  res <- enc_new(e1, e2)
  expect_s3_class(res, "enc_new")
  expect_true(is.numeric(res$statistic))
})

test_that("gw_test unconditional and conditional variants run", {
  set.seed(7)
  n <- 250
  e1 <- rnorm(n)
  e2 <- rnorm(n)
  z <- matrix(rnorm(n), n, 1)
  res_uncond <- gw_test(e1, e2)
  res_cond <- gw_test(e1, e2, instruments = z)
  expect_s3_class(res_uncond, "gw_test")
  expect_s3_class(res_cond, "gw_test")
})
