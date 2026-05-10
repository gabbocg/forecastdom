test_that("uspa_mh_test returns the expected class and components", {
  set.seed(1)
  T_ <- 200; H <- 4
  ld <- matrix(rnorm(T_ * H), T_, H)
  res <- uspa_mh_test(ld, L = 3, B = 199, level = 0.10)
  expect_s3_class(res, "uspa_mh_test")
  expect_named(
    res,
    c("statistic", "pvalue", "reject", "level", "d_bar", "omega",
      "T", "H", "L", "B"),
    ignore.order = TRUE
  )
  expect_length(res$d_bar, H)
  expect_length(res$omega, H)
  expect_equal(res$T, T_)
  expect_equal(res$H, H)
  expect_equal(res$L, 3)
  expect_equal(res$B, 199)
  expect_true(is.finite(res$statistic))
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
  expect_true(is.logical(res$reject))
})

test_that("uspa_mh_test does not reject under H0 of equal mean loss", {
  # Loss diff has mean zero at all horizons -> bench and competitor equal on
  # average. The test should not (often) reject at the 10% level.
  set.seed(123)
  T_ <- 250; H <- 4
  ld <- matrix(rnorm(T_ * H, mean = 0, sd = 1), T_, H)
  res <- uspa_mh_test(ld, L = 3, B = 199, level = 0.10)
  expect_false(res$reject)
})

test_that("uspa_mh_test rejects when benchmark is uniformly worse than competitor", {
  # Loss diff = loss(benchmark) - loss(competitor); under H1: bench worse => d_bar >> 0
  # so the min standardized mean is large positive and the upper-tail bootstrap
  # p-value mean(t < t_b) is near zero.
  set.seed(42)
  T_ <- 250; H <- 4
  ld <- matrix(rnorm(T_ * H, mean = 0.6, sd = 0.5), T_, H)
  res <- uspa_mh_test(ld, L = 3, B = 199, level = 0.10)
  expect_true(res$reject)
})
