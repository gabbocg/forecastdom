test_that("get_legendre returns orthogonal Legendre polynomials on [-1, 1]", {
  x <- seq(-1, 1, length.out = 20001)
  P <- get_legendre(x, 11)
  expect_equal(dim(P), c(length(x), 11L))
  expect_equal(unname(P[length(x), ]), rep(1, 11)) # P_k(1) = 1
  # integral of P_i * P_j over [-1, 1] = 2 / (2k + 1) if i == j, else 0
  G <- crossprod(P) * diff(x)[1]
  expect_lt(max(abs(G - diag(2 / (2 * (0:10) + 1)))), 1e-3)
  expect_equal(get_legendre(x, 1), matrix(1, length(x), 1))
})

test_that("do_prewhiten handles fixed and AIC-selected lags", {
  set.seed(1)
  n <- 2000
  v <- as.numeric(stats::arima.sim(list(ar = 0.6), n = n))
  V <- cbind(v, rnorm(n))

  pw0 <- do_prewhiten(V, lag = 0L)
  expect_equal(pw0$pstar, 0)
  expect_null(pw0$Phi)
  expect_equal(pw0$resid, V)

  pw1 <- do_prewhiten(V, lag = 1L)
  expect_equal(pw1$pstar, 1L)
  expect_equal(dim(pw1$Phi), c(2L, 2L))
  expect_equal(nrow(pw1$resid), n - 1L)
  expect_equal(pw1$Phi[1, 1], 0.6, tolerance = 0.05)

  pw_auto <- do_prewhiten(V, lag = -1L)
  expect_gte(pw_auto$pstar, 1L)
})

test_that("cspa_test returns the documented S3 structure", {
  set.seed(2)
  sim <- do_sim(J = 2, n = 300, a = 1, c = 0, rho_u = 0.4)
  res <- cspa_test(sim$Y, sim$X, level = 0.05, R = 500L)
  expect_s3_class(res, "cspa_test")
  expect_true(res$pvalue >= 0 && res$pvalue <= 1)
  expect_equal(dim(res$h_hat), c(300L, 2L))
  expect_equal(dim(res$sigma_jx), c(2L, 300L))
  expect_equal(res$reject, res$theta < 0)
  expect_output(print(res), "Conditional Superior Predictive Ability")
  expect_output(summary(res), "Per-competitor diagnostics")
})

test_that("cspa_test does not reject when the benchmark dominates everywhere", {
  set.seed(3)
  n <- 500
  X <- rnorm(n)
  Y <- cbind(1 + rnorm(n), 1 + rnorm(n)) # competitor loss - benchmark loss > 0
  res <- cspa_test(Y, X, level = 0.05, R = 1000L)
  expect_false(res$reject)
  expect_gt(res$pvalue, 0.05)
})

test_that("cspa_test p-value agrees with the rejection decision", {
  for (s in 1:5) {
    set.seed(s)
    sim <- do_sim(J = 2, n = 400, a = s - 1, c = 0, rho_u = 0.4)
    res <- cspa_test(sim$Y, sim$X, level = 0.05, R = 500L)
    expect_equal(res$reject, res$pvalue <= 0.05, info = paste("a =", s - 1))
  }
})

test_that("cspa_test rejects when a competitor wins in some states", {
  set.seed(4)
  sim <- do_sim(J = 2, n = 1000, a = 3, c = 0, rho_u = 0.4) # h(x) < 0 near x = 0
  res <- cspa_test(sim$Y, sim$X, level = 0.05, R = 1000L)
  expect_true(res$reject)
  expect_lt(res$pvalue, 0.05)
})

test_that("cspa_test options (trim, prewhiten = 0, no preselection) run", {
  set.seed(5)
  sim <- do_sim(J = 2, n = 300, a = 1, c = 0, rho_u = 0.4)
  res <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 1, prewhiten = 0L,
                   preselect = FALSE, R = 500L)
  expect_lt(length(res$X), 300L)
  expect_true(all(abs(res$X - mean(sim$X)) <= sd(sim$X) + 1e-12))
  expect_equal(res$prewhiten_order, 0L)
  expect_true(all(res$Vhat))
})

test_that("cspa_test errors on mismatched Y and X", {
  expect_error(cspa_test(matrix(rnorm(20), 10), rnorm(9), level = 0.05),
               "same number of observations")
})

test_that("csms keeps the best method and drops a clearly worse one", {
  set.seed(6)
  n <- 500
  X <- rnorm(n)
  losses <- cbind(good = rnorm(n, 1, 0.5),
                  ok   = rnorm(n, 1.1, 0.5),
                  bad  = rnorm(n, 3, 0.5))
  res <- csms(losses, X, level = 0.05, R = 500L, method_names = colnames(losses))
  expect_s3_class(res, "csms")
  expect_true("good" %in% res$set_members)
  expect_false("bad" %in% res$set_members)
  expect_output(print(res), "Confidence Set")
  expect_error(csms(losses, X, level = 0.05, method_names = "a"), "method_names")
})

test_that("cspa_test_plot returns a ggplot for J = 1 and J > 1", {
  set.seed(7)
  sim <- do_sim(J = 2, n = 200, a = 1, c = 0, rho_u = 0.4)
  res <- cspa_test(sim$Y, sim$X, level = 0.05, R = 300L)
  expect_s3_class(cspa_test_plot(res), "ggplot")
  expect_s3_class(cspa_test_plot(Y = sim$Y[, 1, drop = FALSE], X = sim$X),
                  "ggplot")
  expect_error(cspa_test_plot(), "Provide either")
})
