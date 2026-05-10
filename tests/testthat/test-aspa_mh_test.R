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

test_that("at H=1 the aSPA statistic has the same sign as the DM statistic", {
  set.seed(31)
  T_ <- 400
  d <- rnorm(T_, mean = -0.3)
  # Build pseudo-error vectors so dm_test can consume them.
  # Trick: pass d as e1^2 - e2^2 directly via squared-error reconstruction.
  # Easier: use the formula e1 = 0, e2 such that e1^2 - e2^2 = d  =>  e2 = sqrt(-d).
  # That requires d <= 0, which holds in expectation here. Use abs to keep real:
  e1 <- rep(0, T_)
  e2 <- sqrt(pmax(-d, .Machine$double.eps))
  dm <- dm_test(e1, e2, h = 1, correction = FALSE)

  ld <- matrix(d, T_, 1)
  asp <- aspa_mh_test(ld, weights = 1, L = 3, B = 99)

  expect_equal(sign(dm$statistic), sign(asp$statistic))
})
