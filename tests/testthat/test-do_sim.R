test_that("do_sim returns matrices of the requested shape", {
  set.seed(1)
  sim <- do_sim(J = 3, n = 100, a = 1, c = 0, rho_u = 0.4)
  expect_named(sim, c("Y", "X"), ignore.order = TRUE)
  expect_equal(dim(sim$Y), c(100L, 3L))
  expect_length(sim$X, 100L)
  expect_true(all(is.finite(sim$Y)))
  expect_true(all(is.finite(sim$X)))
})
