#' Elliott-Muller Test for Time-Varying Coefficients
#'
#' Computes the \eqn{\hat{qLL}} statistic of Elliott and Muller (2006) for
#' testing the null hypothesis that regression coefficients are constant
#' over time against the alternative of general time variation.
#'
#' @param y Numeric vector of length \code{T}; the dependent variable.
#' @param X A \code{T x k} matrix of regressors linked to potentially
#'   time-varying coefficients.
#' @param Z A \code{T x d} matrix of regressors with constant coefficients.
#'   Use \code{NULL} (default) if all coefficients may vary.
#' @param L Integer; lag truncation for the Newey-West estimator of the
#'   variance. Default \code{0} (no correction).
#'
#' @return A list with class \code{"qll_hat"} containing:
#'   \item{statistic}{The \eqn{\hat{qLL}} test statistic.}
#'   \item{k}{Number of potentially time-varying coefficients.}
#'   \item{n}{Number of observations.}
#'
#' @details
#' The test is based on optimal invariant statistics for the null of
#' constant coefficients against local alternatives. The \eqn{\hat{qLL}}
#' statistic has non-standard critical values that depend on \code{k};
#' see Table 1 in Elliott and Muller (2006).
#'
#' Selected critical values (5\% level):
#' \itemize{
#'   \item \code{k = 1}: -5.91
#'   \item \code{k = 2}: -10.64
#'   \item \code{k = 3}: -15.78
#'   \item \code{k = 4}: -20.62
#'   \item \code{k = 5}: -25.87
#' }
#' Reject the null when \eqn{\hat{qLL}} is below the critical value.
#'
#' @references
#' Elliott, G. and Muller, U.K. (2006). Efficient Tests for General
#' Persistent Time Variation in Regression Coefficients. \emph{Review of
#' Economic Studies}, 73(4), 907-940.
#'
#' @examples
#' \dontrun{
#' set.seed(42)
#' n <- 200
#' x <- matrix(rnorm(n * 2), n, 2)
#' y <- x %*% c(0.5, -0.3) + rnorm(n)
#' qll_hat(y, x)
#' }
#'
#' @importFrom stats lm
#' @export
qll_hat <- function(y, X, Z = NULL, L = 0L) {
  
  y <- as.numeric(y)
  X <- as.matrix(X)
  TT <- length(y)
  k <- ncol(X)

  # OLS regression
  if (is.null(Z)) {
    
    fit <- stats::lm(y ~ X - 1)
    
  } else {
    
    Z <- as.matrix(Z)
    fit <- stats::lm(y ~ X + Z - 1)
    
  }
  
  epsilon_hat <- fit$residuals

  # X * epsilon (score-like quantity)
  X_eps <- X * epsilon_hat  # T x k

  # Newey-West variance estimator
  V_hat <- crossprod(X_eps) / TT
  if (L >= 1) {
    
    for (l in seq_len(L)) {
      
      w_l <- 1 - l / (L + 1)
      Gamma_l <- crossprod(X_eps[(l + 1):nrow(X_eps), , drop = FALSE], X_eps[1:(nrow(X_eps) - l), , drop = FALSE]) / TT
      V_hat <- V_hat + w_l * (Gamma_l + t(Gamma_l))
      
    }
    
  }

  # Standardized residual process
  V_half_inv <- solve(chol(V_hat))
  U_hat <- t(V_half_inv %*% t(X_eps))  # T x k

  # Construct w_hat process
  r_bar <- 1 - 10 / TT
  w_hat <- matrix(0, nrow = TT, ncol = k)
  w_hat[1, ] <- U_hat[1,]
  
  for (t in 2:TT) {
    
    w_hat[t,] <- r_bar * w_hat[t - 1,] + (U_hat[t,] - U_hat[t - 1,])
    
  }

  # Trend regressor
  r_bar_trend <- r_bar^(seq_len(TT))

  # Sum of squared residuals
  SSR <- numeric(k)
  for (i in seq_len(k)) {
    
    fit_i <- stats::lm(w_hat[, i] ~ r_bar_trend - 1)
    SSR[i] <- sum(fit_i$residuals ^ 2)
    
  }

  # qLL-hat statistic
  qLL <- r_bar * sum(SSR) - sum(U_hat ^ 2)

  result <- list(statistic = qLL, k = k, n = TT)
  class(result) <- "qll_hat"
  
  result
  
}

#' @export
print.qll_hat <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  # Critical values at 5% from Elliott and Muller (2006), Table 1
  cv_5pct <- c(-5.91, -10.64, -15.78, -20.62, -25.87)
  cv_label <- if (x$k <= 5) {
    
    formatC(cv_5pct[x$k], digits = 2, format = "f")
    
  } else {
    
    "see Table 1"
    
  }

  reject <- if (x$k <= 5) x$statistic < cv_5pct[x$k] else NA

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Elliott-Muller Test for Time-Varying Coefficients", w)
  .center_line("(Elliott and Muller, 2006)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Constant coefficients (beta(t) = beta)", w)
  .padded_line("H1: Time-varying coefficients", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("qLL-hat statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("5% critical value", cv_label, w)
  if (!is.na(reject)) {
    
    decision <- if (reject) "Rejected ***" else "Not rejected"
    .kv_line("Decision (5%)", decision, w)
    
  }
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (T)", x$n, w)
  .kv_line("Time-varying coefficients (k)", x$k, w)
  .padded_line("Note: Non-standard distribution.", w)
  .padded_line("Reject when qLL-hat < critical value.", w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
