test_that("spa_test returns the documented S3 structure", {
  set.seed(1)
  res <- spa_test(matrix(rnorm(300), 100, 3), level = 0.05, B = 199L)
  expect_s3_class(res, "spa_test")
  expect_gte(res$statistic, 0)
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
  expect_equal(res$reject, res$pvalue < 0.05)
  expect_output(print(res), "Superior Predictive Ability")
})

test_that("spa_test rejects when a competitor clearly beats the benchmark", {
  set.seed(2)
  # Y = competitor loss - benchmark loss; column 3 has lower loss than the benchmark
  Y <- matrix(rnorm(500 * 3, mean = 0.5), 500, 3)
  Y[, 3] <- rnorm(500, mean = -0.3)
  res <- spa_test(Y, level = 0.05, B = 499L)
  expect_true(res$reject)
  expect_equal(res$pvalue, 0)
})

test_that("spa_test does not reject when the benchmark is best", {
  set.seed(3)
  Y <- matrix(rnorm(500 * 3, mean = 0.5), 500, 3)
  res <- spa_test(Y, level = 0.05, B = 499L)
  expect_false(res$reject)
  expect_equal(res$statistic, 0)
})

test_that("clearly inferior competitors do not affect the p-value", {
  set.seed(4)
  n <- 400
  base <- matrix(rnorm(n * 2), n, 2)
  bad <- matrix(rnorm(n * 20, mean = 2), n, 20)
  set.seed(5); p1 <- spa_test(base, level = 0.05, B = 999L)$pvalue
  set.seed(5); p2 <- spa_test(cbind(base, bad), level = 0.05, B = 999L)$pvalue
  expect_equal(p1, p2, tolerance = 0.03)
})

test_that("spa_test has roughly correct size at the null boundary", {
  skip_on_cran()
  set.seed(6)
  rej <- replicate(300, spa_test(matrix(rnorm(250 * 3), 250, 3), level = 0.05, B = 199L)$reject)
  expect_lt(abs(mean(rej) - 0.05), 0.04)
})
