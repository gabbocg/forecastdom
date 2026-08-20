# Shared internal helpers for the multi-horizon SPA tests
# (Quaedvlieg, 2021, "Multi-Horizon Forecast Comparison").

# Moving-block-bootstrap indices (Kunsch, 1989).
# Translated from Get_MBB_ID.m. Block length L, total length T_.
# Each new block starts at a uniform random position in 1:T_; within a block the
# index advances by +1 and wraps to 1 once it exceeds T_.
.mbb_indices <- function(T_, L) {

  idx <- integer(T_)
  idx[1] <- sample.int(T_, 1L)

  for (t in seq.int(2L, T_)) {

    if (t %% L == 0L) {

      idx[t] <- sample.int(T_, 1L)

    } else {

      idx[t] <- idx[t - 1L] + 1L

    }

    if (idx[t] > T_) idx[t] <- 1L

  }

  idx

}

# MBB "natural variance" estimator (Quaedvlieg, 2021; MBB_Variance.m).
# y is T x N. Returns a length-N vector. Mirrors the Matlab reshape:
# columns are unrolled into K x L matrices (K rows, L cols), then we take
# the mean of squared row-sums divided by L.
.mbb_variance <- function(y, L) {

  y <- as.matrix(y)
  T_ <- nrow(y)
  N  <- ncol(y)
  K  <- T_ %/% L

  ydem <- sweep(y, 2, colMeans(y))
  omega <- numeric(N)

  for (n in seq_len(N)) {

    blocks <- matrix(ydem[seq_len(K * L), n], nrow = K, ncol = L, byrow = FALSE)
    omega[n] <- mean(rowSums(blocks) ^ 2) / L

  }

  omega

}

# Quadratic-Spectral kernel weights (Andrews, 1991; QS_Weights.m).
.qs_weights <- function(x) {

  a <- 6 * pi * x / 5
  out <- (3 / a ^ 2) * (sin(a) / a - cos(a))
  out[x == 0] <- 1
  out

}

# Column-wise Quadratic-Spectral HAC long-run variance.
# Translation of QS.m. Bandwidth bw = 1.3 * T^(1/5). y is T x N.
.qs_lrvar <- function(y) {

  y <- as.matrix(y)
  T_ <- nrow(y)
  N  <- ncol(y)
  bw <- 1.3 * T_ ^ (1 / 5)
  w  <- .qs_weights(seq_len(T_ - 1L) / bw)

  omega <- numeric(N)
  for (i in seq_len(N)) {

    z <- y[, i] - mean(y[, i])
    g0 <- sum(z * z) / T_
    cross <- 0
    for (j in seq_len(T_ - 1L)) {

      cross <- cross + 2 * w[j] * sum(z[seq_len(T_ - j)] * z[(j + 1L):T_]) / T_

    }
    
    omega[i] <- g0 + cross

  }

  omega

}
