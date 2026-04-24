#' Compute Legendre Polynomial Basis Matrix
#'
#' Evaluates Legendre polynomials up to order \code{K} at the points in
#' \code{x}. Used internally for series estimation in the CSPA test.
#'
#' @param x Numeric vector of evaluation points, typically in \eqn{[-1, 1]}.
#' @param K Integer, number of basis functions (columns) to return.
#'
#' @return An \code{n x K} matrix where column \code{k} contains the
#'   \code{(k-1)}-th Legendre polynomial evaluated at \code{x}.
#'
#' @keywords internal
get_legendre <- function(x, K) {
  
  n <- length(x)
  P <- matrix(1, nrow = n, ncol = K)

  if (K > 1)  P[, 2]  <- x
  if (K > 2)  P[, 3]  <- 0.5 * (3 * x ^ 2 - 1)
  if (K > 3)  P[, 4]  <- 0.5 * (5 * x ^ 3 - 3 * x)
  if (K > 4)  P[, 5]  <- 0.125 * (35 * x ^ 4 - 30 * x ^ 2 + 3)
  if (K > 5)  P[, 6]  <- 0.125 * (63 * x ^ 5 - 70 * x ^ 3 + 15 * x)
  if (K > 6)  P[, 7]  <- (1 / 16) * (231 * x ^ 6 - 315 * x ^ 4 + 105 * x ^ 2 - 5)
  if (K > 7)  P[, 8]  <- (1 / 16) * (429 * x ^ 7 - 693 * x ^ 5 + 315 * x ^ 3 - 35 * x)
  if (K > 8)  P[, 9]  <- (1 / 128) * (6435 * x ^ 8 - 12012 * x ^ 6 + 6930 * x ^ 4 - 1260 * x ^ 2 + 35)
  if (K > 9)  P[, 10] <- (1 / 128) * (12155 * x ^ 9 - 25740 * x ^ 7 + 18018 * x ^ 5 - 4620 * x ^ 3 + 315 * x)
  if (K > 10) P[, 11] <- (1 / 256) * (46189 * x ^ 10 - 109395 * x ^ 8 + 90090 * x ^ 6 - 30030 * x ^ 4 + 3465 * x ^ 2 - 63)

  P
  
}
