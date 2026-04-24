#' Pre-Whiten a Multivariate Time Series
#'
#' Fits a VAR model to pre-whiten the data for HAC estimation. The lag order
#' can be selected automatically via AIC.
#'
#' @param V A \code{T x K} numeric matrix.
#' @param lag Integer lag order. Use \code{-1} (default) for AIC-based
#'   selection (up to 4 lags).
#'
#' @return A list with components:
#'   \item{resid}{Residual matrix after pre-whitening.}
#'   \item{Phi}{Estimated VAR coefficient matrix (stacked by lag).}
#'   \item{pstar}{Selected lag order.}
#'
#' @importFrom stats cov
#' @keywords internal
do_prewhiten <- function(V, lag = -1L) {
  
  V <- as.matrix(V)
  n <- nrow(V)
  K <- ncol(V)

  if (lag == -1L) {
    
    Vt <- V[5:n, , drop = FALSE]
    Vt1 <- cbind(V[4:(n - 1), , drop = FALSE],
                 V[3:(n - 2), , drop = FALSE],
                 V[2:(n - 3), , drop = FALSE],
                 V[1:(n - 4), , drop = FALSE])

    aic <- numeric(5)
    aic[1] <- log(det(stats::cov(Vt)))

    for (p in 1:4) {
      
      Vt1_p <- Vt1[, 1:(p * K), drop = FALSE]
      Phi_p <- solve(crossprod(Vt1_p), crossprod(Vt1_p, Vt))
      resid_p <- Vt - Vt1_p %*% Phi_p
      aic[p + 1] <- log(det(stats::cov(resid_p))) + (2 * p * K ^ 2) / (n - 4)
      
    }

    pstar <- which.min(aic) - 1L
    
  } else {
    
    pstar <- lag
    
  }

  if (pstar > 0) {
    
    Vt <- V[(pstar + 1):n, , drop = FALSE]
    Vt1 <- do.call(cbind, lapply(1:pstar, function(p) {
      
      V[(pstar + 1 - p):(n - p), , drop = FALSE]
      
    }))
    
    Phi <- solve(crossprod(Vt1), crossprod(Vt1, Vt))
    resid <- Vt - Vt1 %*% Phi
    
  } else {
    
    resid <- V
    Phi <- NULL
    
  }

  list(resid = resid, Phi = Phi, pstar = pstar)
  
}
