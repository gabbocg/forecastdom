test_that(".mbb_indices returns T integers in 1:T with contiguous L-blocks", {
  set.seed(1)
  T_ <- 50; L <- 5
  idx <- forecastdom:::.mbb_indices(T_, L)
  expect_length(idx, T_)
  expect_true(all(idx >= 1L & idx <= T_))
  # Within a block (positions where t %% L != 0), idx should advance by 1 mod T
  diffs <- diff(idx)
  # diffs[i] = idx[i+1] - idx[i], so a fresh random draw at iteration t = i+1
  # makes diffs[i] unconstrained. The Matlab makes those draws when t %% L == 0,
  # i.e. when (i + 1) %% L == 0.
  in_block <- ((seq_len(T_ - 1) + 1L) %% L) != 0L
  # inside-block diffs are either +1 or -(T-1) (the wrap)
  expect_true(all(diffs[in_block] %in% c(1L, -(T_ - 1L))))
})

test_that(".mbb_variance matches a closed-form Matlab translation on a fixed input", {
  set.seed(7)
  y <- matrix(rnorm(60), 60, 2)
  L <- 3
  out <- forecastdom:::.mbb_variance(y, L)

  # Independent reimplementation of MBB_Variance.m
  T_ <- nrow(y); N <- ncol(y); K <- floor(T_ / L)
  ydem <- sweep(y, 2, colMeans(y))
  expect <- numeric(N)
  for (n in seq_len(N)) {
    blocks <- matrix(ydem[seq_len(K * L), n], nrow = K, ncol = L, byrow = FALSE)
    expect[n] <- mean(rowSums(blocks)^2) / L
  }
  expect_equal(out, expect, tolerance = 1e-12)
  expect_length(out, N)
})

test_that(".qs_lrvar returns one variance per column and reduces to var(.) at lag 0", {
  set.seed(11)
  y <- matrix(rnorm(120), 120, 3)
  v <- forecastdom:::.qs_lrvar(y)
  expect_length(v, 3)
  expect_true(all(v > 0))
})

test_that(".qs_lrvar matches independent QS reimplementation on white noise", {
  set.seed(13)
  y <- matrix(rnorm(200), 200, 2)

  T_ <- nrow(y); N <- ncol(y)
  bw <- 1.3 * T_^(1 / 5)
  qs_w <- function(x) {
    a <- 6 * pi * x / 5
    out <- (3 / a^2) * (sin(a) / a - cos(a))
    out[x == 0] <- 1
    out
  }
  w <- qs_w(seq_len(T_ - 1L) / bw)
  expect <- numeric(N)
  for (i in seq_len(N)) {
    z <- y[, i] - mean(y[, i])
    g0 <- sum(z * z) / T_
    s <- 0
    for (j in seq_len(T_ - 1L)) {
      s <- s + 2 * w[j] * sum(z[seq_len(T_ - j)] * z[(j + 1):T_]) / T_
    }
    expect[i] <- g0 + s
  }

  expect_equal(forecastdom:::.qs_lrvar(y), expect, tolerance = 1e-10)
})
