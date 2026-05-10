test_that("aspa_mh_test returns the documented S3 structure", {
  set.seed(7)
  ld <- matrix(rnorm(200 * 5, mean = -0.1), 200, 5)
  res <- aspa_mh_test(ld, weights = rep(1 / 5, 5), L = 3, B = 99)

  expect_s3_class(res, "aspa_mh_test")
  expect_named(res, c("statistic", "pvalue", "reject", "level",
                      "L", "B", "T", "H", "weights", "d_bar"))
  expect_equal(sum(res$weights), 1)
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
})

test_that("aspa_mh_test errors on weight/horizon mismatch", {
  ld <- matrix(rnorm(60), 30, 2)
  expect_error(aspa_mh_test(ld, weights = c(0.5, 0.3, 0.2), L = 2),
               regexp = "weights")
})

test_that("aspa_mh_test rejects when the weighted average favors the competitor", {
  # Loss diff = L_bench - L_comp; under H1 (bench worse on weighted average)
  # => weighted d_bar >> 0 => t large positive => upper-tail p-value near zero.
  set.seed(99)
  T_ <- 250; H <- 4
  ld <- matrix(rnorm(T_ * H, mean = 0.5), T_, H)
  res <- aspa_mh_test(ld, weights = rep(1 / H, H), L = 3, B = 199, level = 0.10)
  expect_true(res$reject)
})
