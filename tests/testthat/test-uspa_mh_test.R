# Reference value from running Test_uSPA(LossDiff_uSPA, 3) in Matlab/Octave.
# Set this to the actual Matlab statistic to enable the cross-language parity test.
MATLAB_USPA_STAT <- NULL

test_that("uspa_mh_test returns the documented S3 structure", {
  set.seed(2024)
  T_ <- 200; H <- 5
  ld <- matrix(rnorm(T_ * H, mean = 0.05, sd = 1), T_, H)
  res <- uspa_mh_test(ld, L = 3, B = 99)

  expect_s3_class(res, "uspa_mh_test")
  expect_named(res, c("statistic", "pvalue", "reject", "level",
                      "L", "B", "T", "H", "d_bar"))
  expect_length(res$d_bar, H)
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
})

test_that("uspa_mh_test is reproducible under a fixed seed", {
  set.seed(99)
  ld <- matrix(rnorm(150 * 4), 150, 4)
  set.seed(1); a <- uspa_mh_test(ld, L = 3, B = 99)$pvalue
  set.seed(1); b <- uspa_mh_test(ld, L = 3, B = 99)$pvalue
  expect_identical(a, b)
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

test_that("uspa_mh_test statistic matches a direct helper computation on the bundled dataset", {
  ld <- quaedvlieg2021$uspa
  T_ <- nrow(ld); H <- ncol(ld)
  expected <- min(sqrt(T_) * colMeans(ld) / sqrt(forecastdom:::.qs_lrvar(ld)))

  set.seed(2024)
  res <- uspa_mh_test(ld, L = 3, B = 99)
  expect_equal(res$statistic, expected, tolerance = 1e-12)
})

test_that("uspa_mh_test statistic matches the Matlab reference (gated)", {
  skip_if_not(!is.null(MATLAB_USPA_STAT),
              "Set MATLAB_USPA_STAT at the top of this file to enable Matlab parity check.")
  set.seed(1)
  res <- uspa_mh_test(quaedvlieg2021$uspa, L = 3, B = 99)
  expect_equal(res$statistic, MATLAB_USPA_STAT, tolerance = 1e-8)
})
