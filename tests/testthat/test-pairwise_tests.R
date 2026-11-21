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

test_that("dm_test alternative = 'greater' rejects when the competitor is clearly better", {
  set.seed(2)
  n <- 500
  e1 <- rnorm(n, sd = 1.5)
  e2 <- rnorm(n, sd = 0.5)
  expect_lt(dm_test(e1, e2, alternative = "greater")$pvalue, 0.01)
  expect_gt(dm_test(e1, e2, alternative = "less")$pvalue, 0.99)
})

test_that("dm_test prints the alternative with the direction it tests", {
  set.seed(3)
  e1 <- rnorm(150)
  e2 <- rnorm(150)
  expect_output(print(dm_test(e1, e2, alternative = "less")),
                "H1: Model 2 is less accurate than model 1")
  expect_output(print(dm_test(e1, e2, alternative = "greater")),
                "H1: Model 2 is more accurate than model 1")
})

# Forecast errors whose loss differential is MA(h - 1), as for overlapping
# h-step forecasts.
ma_errors <- function(n, h, sd = 1) {
  eps <- rnorm(n + h - 1, sd = sd)
  as.numeric(stats::filter(eps, rep(1, h), sides = 1))[h:(n + h - 1)]
}

test_that("dm_test matches forecast::dm.test for SE and AE loss at h = 1 and h > 1", {
  skip_if_not_installed("forecast")
  cases <- list(
    list(seed = 11, n = 120, h = 1),
    list(seed = 12, n = 80,  h = 1),
    list(seed = 13, n = 200, h = 3),
    list(seed = 14, n = 300, h = 6)
  )
  for (cs in cases) {
    set.seed(cs$seed)
    e1 <- ma_errors(cs$n, cs$h)
    e2 <- ma_errors(cs$n, cs$h, sd = 1.2) + 0.1 * rt(cs$n, df = 5)
    for (loss in c("SE", "AE")) {
      power <- if (loss == "SE") 2 else 1
      for (alt in c("two.sided", "less", "greater")) {
        ref <- expect_no_warning(
          forecast::dm.test(e1, e2, alternative = alt, h = cs$h, power = power)
        )
        res <- dm_test(e1, e2, h = cs$h, loss = loss, alternative = alt)
        label <- sprintf("seed %d, h = %d, %s, %s", cs$seed, cs$h, loss, alt)
        expect_equal(res$statistic, unname(ref$statistic), tolerance = 1e-10, label = label)
        expect_equal(res$pvalue, unname(ref$p.value), tolerance = 1e-10, label = label)
      }
    }
  }
})

test_that("dm_test without the HLN correction is dm.test's statistic undone by the HLN factor, on N(0, 1)", {
  skip_if_not_installed("forecast")
  set.seed(15)
  n <- 150
  for (h in c(1L, 4L)) {
    e1 <- ma_errors(n, h)
    e2 <- ma_errors(n, h, sd = 1.3)
    ref <- forecast::dm.test(e1, e2, h = h)
    # Harvey, Leybourne and Newbold (1997), eq. (9).
    hln <- sqrt((n + 1 - 2 * h + h * (h - 1) / n) / n)
    stat <- unname(ref$statistic) / hln
    res <- dm_test(e1, e2, h = h, correction = FALSE)
    expect_equal(res$statistic, stat, tolerance = 1e-10)
    expect_equal(res$pvalue, 2 * pnorm(-abs(stat)), tolerance = 1e-10)
  }
})

test_that("dm_test stops when the long-run variance is not positive", {
  n <- 100
  e2 <- rep(1, n)
  # Equal losses: zero variance at h = 1.
  expect_error(dm_test(e2, e2), "long-run variance")
  # Alternating loss differential: the lag-1 autocovariance outweighs the
  # variance, so the h = 2 estimate is negative.
  e1 <- sqrt(1 + 0.5 * (-1) ^ seq_len(n))
  expect_error(dm_test(e1, e2, h = 2), "long-run variance")
})

test_that("dm_test, cw_test and gw_test reject a horizon that is not a positive integer", {
  set.seed(16)
  e1 <- rnorm(50)
  e2 <- rnorm(50)
  for (h in list(0, -1, 1.5, NA_real_, c(1, 2))) {
    expect_error(dm_test(e1, e2, h = h), "h must be")
    expect_error(cw_test(e1, e2, e1, e2, h = h), "h must be")
    expect_error(gw_test(e1, e2, h = h), "h must be")
  }
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

# Reference Clark-West statistic: OLS of the MSFE-adjusted series on a
# constant, with a Newey-West (Bartlett) standard error from sandwich.
cw_reference <- function(e1, e2, f1, f2, lag) {
  adj <- e1 ^ 2 - (e2 ^ 2 - (f1 - f2) ^ 2)
  fit <- stats::lm(adj ~ 1)
  se <- sqrt(sandwich::NeweyWest(fit, lag = lag, prewhite = FALSE, adjust = FALSE)[1, 1])
  stat <- unname(stats::coef(fit)) / se
  list(statistic = stat, pvalue = stats::pnorm(stat, lower.tail = FALSE))
}

cw_fixture <- function(n, h) {
  set.seed(21)
  x <- as.numeric(stats::arima.sim(list(ar = 0.8), n))
  y <- 0.2 * x + ma_errors(n, h)
  f1 <- rep(0.05, n)
  f2 <- 0.25 * x
  list(e1 = y - f1, e2 = y - f2, f1 = f1, f2 = f2)
}

test_that("cw_test at h = 1 is the t-statistic with the sample-variance standard error", {
  skip_if_not_installed("sandwich")
  fx <- cw_fixture(240, 1)
  ref <- cw_reference(fx$e1, fx$e2, fx$f1, fx$f2, lag = 0)
  res <- cw_test(fx$e1, fx$e2, fx$f1, fx$f2)
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
  expect_equal(res$pvalue, ref$pvalue, tolerance = 1e-10)
})

test_that("cw_test at h > 1 uses Newey-West with Clark and West's 1.5h bandwidth", {
  skip_if_not_installed("sandwich")
  h <- 4
  fx <- cw_fixture(300, h)
  # Clark and West (2007, Section 5): bandwidth 1.5 * h for h-step forecasts.
  ref <- cw_reference(fx$e1, fx$e2, fx$f1, fx$f2, lag = floor(1.5 * h))
  res <- cw_test(fx$e1, fx$e2, fx$f1, fx$f2, h = h)
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
  expect_equal(res$pvalue, ref$pvalue, tolerance = 1e-10)
})

test_that("cw_test uses the lag count the caller gives", {
  skip_if_not_installed("sandwich")
  h <- 4
  fx <- cw_fixture(300, h)
  ref <- cw_reference(fx$e1, fx$e2, fx$f1, fx$f2, lag = h - 1)
  res <- cw_test(fx$e1, fx$e2, fx$f1, fx$f2, h = h, nlag = h - 1)
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
})

test_that("cw_test rejects a lag count that is not a non-negative integer below n", {
  fx <- cw_fixture(60, 1)
  for (nlag in list(-1, 2.5, NA_real_, 60)) {
    expect_error(cw_test(fx$e1, fx$e2, fx$f1, fx$f2, nlag = nlag), "nlag must be")
  }
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

# Reference Giacomini-White Wald statistic: the moments Z_t = d_t * W_t
# regressed on a constant, with their Newey-West covariance from sandwich.
gw_reference <- function(d, W, lag) {
  Z <- W * d
  fit <- stats::lm(Z ~ 1)
  V <- sandwich::NeweyWest(fit, lag = lag, prewhite = FALSE, adjust = FALSE)
  m <- stats::coef(fit)[1, ]
  wald <- as.numeric(t(m) %*% solve(V, m))
  list(statistic = wald, pvalue = stats::pchisq(wald, df = ncol(W), lower.tail = FALSE))
}

gw_fixture <- function(n, h) {
  set.seed(31)
  list(e1 = ma_errors(n, h), e2 = ma_errors(n, h, sd = 1.1))
}

test_that("gw_test default instruments at h = 1 are a constant and the loss differential lagged once", {
  skip_if_not_installed("sandwich")
  n <- 200
  fx <- gw_fixture(n, 1)
  d <- fx$e1 ^ 2 - fx$e2 ^ 2
  ref <- gw_reference(d[2:n], cbind(1, d[1:(n - 1)]), lag = 0)
  res <- gw_test(fx$e1, fx$e2)
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
  expect_equal(res$pvalue, ref$pvalue, tolerance = 1e-10)
  expect_equal(res$n, n - 1)
})

test_that("gw_test default instruments at h > 1 lag the loss differential by h", {
  skip_if_not_installed("sandwich")
  n <- 300
  h <- 4
  fx <- gw_fixture(n, h)
  d <- abs(fx$e1) - abs(fx$e2)
  # d_{t+h} is instrumented by d_t, the last loss differential known at the
  # forecast origin t.
  ref <- gw_reference(d[(h + 1):n], cbind(1, d[1:(n - h)]), lag = floor(1.5 * h))
  res <- gw_test(fx$e1, fx$e2, h = h, loss = "AE")
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
  expect_equal(res$pvalue, ref$pvalue, tolerance = 1e-10)
  expect_equal(res$n, n - h)
})

test_that("gw_test uses the lag count the caller gives, as Giacomini and White's code does with h - 1", {
  skip_if_not_installed("sandwich")
  n <- 300
  h <- 4
  fx <- gw_fixture(n, h)
  d <- fx$e1 ^ 2 - fx$e2 ^ 2
  ref <- gw_reference(d[(h + 1):n], cbind(1, d[1:(n - h)]), lag = h - 1)
  res <- gw_test(fx$e1, fx$e2, h = h, nlag = h - 1)
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
})

test_that("gw_test with user instruments at h > 1 matches the Newey-West Wald statistic", {
  skip_if_not_installed("sandwich")
  n <- 250
  h <- 3
  fx <- gw_fixture(n, h)
  set.seed(32)
  W <- cbind(1, rnorm(n), rexp(n))
  d <- fx$e1 ^ 2 - fx$e2 ^ 2
  ref <- gw_reference(d, W, lag = floor(1.5 * h))
  res <- gw_test(fx$e1, fx$e2, instruments = W, h = h)
  expect_equal(res$statistic, ref$statistic, tolerance = 1e-10)
  expect_equal(res$pvalue, ref$pvalue, tolerance = 1e-10)
  expect_equal(res$df, 3)
})

test_that("gw_test stops naming the collinear instruments when the moment covariance is singular", {
  set.seed(33)
  n <- 200
  e1 <- rnorm(n)
  e2 <- rnorm(n)
  z <- rnorm(n)
  W <- cbind(const = 1, z = z, z_scaled = 2 * z, u = rnorm(n))
  err <- expect_error(gw_test(e1, e2, instruments = W), "singular")
  msg <- conditionMessage(err)
  expect_match(msg, "\\bz\\b")
  expect_match(msg, "\\bz_scaled\\b")
  expect_no_match(msg, "\\bconst\\b")
  expect_no_match(msg, "\\bu\\b")
})
