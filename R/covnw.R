#' Newey-West Long-Run Covariance Estimator
#'
#' Estimates the long-run covariance matrix using Newey-West (Bartlett) weights.
#'
#' @param data A \code{T x K} numeric matrix.
#' @param nlag Non-negative integer lag length. If \code{NULL} (default),
#'   uses \code{floor(1.2 * T^(1/3))}.
#' @param demean Logical; subtract column means before estimation? Default
#'   \code{TRUE}.
#'
#' @return A \code{K x K} covariance matrix.
#'
#' @keywords internal
covnw <- function(data, nlag = NULL, demean = TRUE) {
  
  data <- as.matrix(data)
  n <- nrow(data)

  if (is.null(nlag)) {
    
    nlag <- min(floor(1.2 * n^(1 / 3)), n)
    
  }

  if (demean) {
    
    data <- sweep(data, 2, colMeans(data))
    
  }

  w <- (nlag + 1 - 0:nlag) / (nlag + 1)

  V <- crossprod(data) / n

  for (i in seq_len(nlag)) {
    
    Gamma_i <- crossprod(data[(i + 1):n, , drop = FALSE], data[1:(n - i), , drop = FALSE]) / n
    
    V <- V + w[i + 1] * (Gamma_i + t(Gamma_i))
    
  }

  V
  
}
