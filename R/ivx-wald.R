#' IVX-Wald Test for Predictive Regressions
#'
#' Computes the IVX-Wald statistic of Kostakis, Magdalinos, and
#' Stamatogiannis (2015) for testing predictability in a regression of
#' returns on persistent predictors. The IVX approach is robust to the
#' degree of persistence of the regressors (stationary, local-to-unity,
#' or unit root).
#'
#' @param y Numeric vector of length \code{T}; the dependent variable
#'   (e.g., returns).
#' @param X A \code{T x r} matrix of predictor observations.
#' @param K Integer; forecast horizon. Default \code{1}.
#' @param M_n Integer; bandwidth parameter for the long-run covariance
#'   estimator. Default \code{0} (no correction). Use
#'   \code{floor(T^(1/3))} as a rule of thumb.
#' @param beta Numeric in \eqn{(0, 1)}; controls the rate of the
#'   IVX instrument. Values close to 1 yield best performance. Default
#'   \code{0.95}.
#'
#' @return A list with class \code{"ivx_wald"} containing:
#'   \item{statistic}{The IVX-Wald test statistic.}
#'   \item{pvalue}{P-value from the chi-squared distribution.}
#'   \item{coefficients}{IVX coefficient estimates.}
#'   \item{K}{Forecast horizon.}
#'   \item{n}{Number of observations.}
#'   \item{r}{Number of predictors.}
#'
#' @details
#' The IVX-Wald test constructs an endogenous instrument
#' \eqn{\tilde{Z}_t} by filtering the predictor increments through a
#' mildly integrated process with autoregressive root
#' \eqn{R_{nz} = 1 - 1/n^\beta}. The resulting Wald statistic is
#' asymptotically chi-squared with \code{r} degrees of freedom,
#' regardless of the persistence of the predictors.
#'
#' @references
#' Kostakis, A., Magdalinos, T., and Stamatogiannis, M.P. (2015). Robust
#' Econometric Inference for Stock Return Predictability. \emph{Review of
#' Financial Studies}, 28(5), 1506-1553.
#'
#' @examples
#' set.seed(42)
#' n <- 200
#' x <- cumsum(rnorm(n))
#' y <- 0.02 * x + rnorm(n)
#' ivx_wald(y, as.matrix(x))
#'
#' @importFrom stats lm pchisq
#' @export
ivx_wald <- function(y, X, K = 1L, M_n = 0L, beta = 0.95) {
  
  y <- as.numeric(y)
  X <- as.matrix(X)
  TT <- length(y)
  r <- ncol(X)

  # OLS of y on lagged X
  y_reg <- y[2:TT]
  X_reg <- X[1:(TT - 1), , drop = FALSE]
  fit_y <- stats::lm(y_reg ~ X_reg)
  epsilon_hat <- fit_y$residuals
  n_eps <- length(epsilon_hat)

  # AR(1) residuals for each predictor
  U_hat <- matrix(NA_real_, nrow = TT - 1, ncol = r)
  for (j in seq_len(r)) {
    
    fit_j <- stats::lm(X[2:TT, j] ~ X[1:(TT - 1), j])
    U_hat[, j] <- fit_j$residuals
    
  }

  # Covariance estimates
  Sigma_ee <- drop(crossprod(epsilon_hat)) / n_eps
  Sigma_eu <- crossprod(epsilon_hat, U_hat) / n_eps
  Sigma_uu <- crossprod(U_hat) / n_eps

  Omega_uu <- Sigma_uu
  Omega_eu <- Sigma_eu

  if (M_n > 0) {
    
    Lambda_uu <- matrix(0, r, r)
    Lambda_ue <- matrix(0, r, 1)
    
    for (h in seq_len(M_n)) {
      
      w_h <- 1 - h / (M_n + 1)
      Lambda_uu <- Lambda_uu + w_h / n_eps * crossprod(U_hat[(h + 1):nrow(U_hat), , drop = FALSE], U_hat[1:(nrow(U_hat) - h), , drop = FALSE])
      Lambda_ue <- Lambda_ue + w_h / n_eps * crossprod(U_hat[(h + 1):nrow(U_hat), , drop = FALSE], epsilon_hat[1:(length(epsilon_hat) - h)])
    
    }
    
    Omega_uu <- Sigma_uu + Lambda_uu + t(Lambda_uu)
    Omega_eu <- Sigma_eu + t(Lambda_ue)
    
  }

  # IVX instrument construction
  R_nz <- 1 - 1 / (TT - 1) ^ beta
  d_X <- rbind(rep(0, r), diff(X))
  Z_tilde <- matrix(0, nrow = TT, ncol = r)
  
  for (t in 2:TT) {
    
    Z_tilde[t, ] <- R_nz * Z_tilde[t - 1, ] + d_X[t,]
    
  }

  # K-period aggregation (faithful to Compute_IVX_Wald.m, Sec 5.1 KMS)
  L_agg <- TT - (K - 1L)
  y_K <- numeric(L_agg)
  X_K <- matrix(0, L_agg, r)
  Z_K <- matrix(0, L_agg, r)

  for (t in seq_len(L_agg)) {

    y_K[t]   <- sum(y[t:(t + K - 1L)])
    X_K[t, ] <- colSums(X[t:(t + K - 1L), , drop = FALSE])
    Z_K[t, ] <- colSums(Z_tilde[t:(t + K - 1L), , drop = FALSE])

  }

  # Demean using MATLAB indexing: y_K(2:end), X_K(1:end-1), Z_K(1:end-K)
  n_K        <- L_agg - 1L
  y_bar      <- mean(y_K[2:L_agg])
  x_bar      <- colMeans(X_K[1:(L_agg - 1L), , drop = FALSE])
  z_bar      <- colMeans(Z_K[1:(L_agg - K), , drop = FALSE])
  Y_dm       <- y_K[2:L_agg] - y_bar
  X_dm       <- sweep(X_K[1:(L_agg - 1L), , drop = FALSE], 2, x_bar)
  Z_K_use    <- Z_K[1:(L_agg - 1L), , drop = FALSE]
  Z_use      <- Z_tilde[1:(TT - K), , drop = FALSE]

  # IVX coefficient estimate (eq. 33)
  A_ivx <- solve(crossprod(X_dm, Z_use), crossprod(Z_use, Y_dm))

  # Variance of IVX estimator (eq. 34)
  Omega_FM <- Sigma_ee - Omega_eu %*% solve(Omega_uu) %*% t(Omega_eu)
  M_K_mat  <- crossprod(Z_K_use) * drop(Sigma_ee) - n_K * tcrossprod(z_bar) * drop(Omega_FM)
  Q_H      <- solve(crossprod(Z_use, X_dm)) %*% M_K_mat %*% solve(crossprod(X_dm, Z_use))

  # Wald statistic
  W_ivx <- drop(t(A_ivx) %*% solve(Q_H) %*% A_ivx)
  pval <- stats::pchisq(W_ivx, df = r, lower.tail = FALSE)

  result <- list(statistic = W_ivx, pvalue = pval, coefficients = drop(A_ivx), K = K, n = TT, r = r)
  class(result) <- "ivx_wald"
  
  result
  
}

#' @export
print.ivx_wald <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("IVX-Wald Test for Predictive Regressions", w)
  .center_line("(Kostakis, Magdalinos, and Stamatogiannis, 2015)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: No predictability (all coefficients = 0)", w)
  .padded_line("H1: At least one predictor is significant", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("IVX-Wald statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value", formatC(x$pvalue, digits = digits, format = "f"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (T)", x$n, w)
  .kv_line("Predictors (r)", x$r, w)
  .kv_line("Forecast horizon (K)", x$K, w)
  .kv_line("Reference distribution", paste0("Chi-sq(", x$r, ")"), w)

  if (x$r <= 5) {
    
    cat("\u251C", dot, "\u2524\n", sep = "")
    .padded_line("IVX Coefficients:", w)
    
    for (j in seq_along(x$coefficients)) {
      
      .kv_line(paste0("  beta_", j), formatC(x$coefficients[j], digits = digits, format = "f"), w)
    
    }
    
  }

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
