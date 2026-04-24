#' Conditional Equal Predictive Ability (CEPA) Test
#'
#' Tests the null hypothesis of conditional equal predictive ability using
#' the Giacomini and White (2006) approach. The test checks whether loss
#' differentials are conditionally mean-zero given an information set,
#' using a finite set of instruments.
#'
#' @param e1 Numeric vector of forecast errors from model 1 (benchmark).
#' @param e2 Numeric vector of forecast errors from model 2 (competitor).
#' @param instruments An \code{n x q} matrix of instruments (conditioning
#'   variables) observed at the time of the forecast. If \code{NULL}
#'   (default), uses a constant and the lagged loss differential.
#' @param loss Character; loss function. \code{"SE"} for squared error
#'   (default), \code{"AE"} for absolute error.
#'
#' @return A list with class \code{"gw_test"} containing:
#'   \item{statistic}{The Wald test statistic.}
#'   \item{pvalue}{P-value from the chi-squared distribution.}
#'   \item{df}{Degrees of freedom (number of instruments).}
#'   \item{n}{Number of observations used.}
#'   \item{loss}{Loss function used.}
#'
#' @details
#' The test is based on the unconditional moment conditions implied by
#' the CEPA null hypothesis:
#' \deqn{E[d_t \cdot W_t] = 0}
#' where \eqn{d_t} is the loss differential and \eqn{W_t} is a vector of
#' instruments measurable with respect to the conditioning information set.
#'
#' The test statistic follows a chi-squared distribution with \eqn{q}
#' degrees of freedom, where \eqn{q} is the number of instruments.
#'
#' @references
#' Giacomini, R. and White, H. (2006). Tests of Conditional Predictive
#' Ability. \emph{Econometrica}, 74(6), 1545-1578.
#'
#' @examples
#' set.seed(42)
#' e1 <- rnorm(200)
#' e2 <- rnorm(200, sd = 0.9)
#' gw_test(e1, e2)
#'
#' @importFrom stats pchisq
#' @export
gw_test <- function(e1, e2, instruments = NULL, loss = c("SE", "AE")) {
  
  loss <- match.arg(loss)
  e1 <- as.numeric(e1)
  e2 <- as.numeric(e2)

  if (length(e1) != length(e2)) {
    
    stop("e1 and e2 must have the same length.")
    
  }

  n_full <- length(e1)

  # Loss differentials
  if (loss == "SE") {
    
    d <- e1 ^ 2 - e2 ^ 2
    
  } else {
    
    d <- abs(e1) - abs(e2)
    
  }

  if (is.null(instruments)) {
    
    # Default: constant and lagged loss differential
    d_lag <- d[-n_full]
    d <- d[-1]
    W <- cbind(1, d_lag)
    n <- n_full - 1
    
  } else {
    
    instruments <- as.matrix(instruments)
    
    if (nrow(instruments) != n_full) {
      
      stop("instruments must have the same number of rows as e1.")
      
    }
    
    W <- instruments
    n <- n_full
    
  }

  q <- ncol(W)

  # Instrumented moments: d_t * W_t
  dW <- W * d  # n x q

  # Sample mean
  m_bar <- colMeans(dW)

  # HAC variance (Newey-West)
  Sigma <- covnw(dW) / n

  # Wald statistic
  Sigma_inv <- tryCatch(solve(Sigma), error = function(e) {
    
    MASS::ginv(Sigma)
    
  })
  
  wald <- as.numeric(t(m_bar) %*% Sigma_inv %*% m_bar)

  pval <- stats::pchisq(wald, df = q, lower.tail = FALSE)

  result <- list(statistic = wald, pvalue = pval, df = q, n = n, loss = loss)
  class(result) <- "gw_test"
  
  result
  
}

#' @export
print.gw_test <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Conditional Equal Predictive Ability Test", w)
  .center_line("(Giacomini and White, 2006)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Equal conditional predictive ability", w)
  .padded_line("H1: Methods differ conditionally", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("Wald statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value", formatC(x$pvalue, digits = digits, format = "f"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (n)", x$n, w)
  .kv_line("Instruments (q)", x$df, w)
  .kv_line("Loss function", x$loss, w)
  .kv_line("Reference distribution", paste0("Chi-sq(", x$df, ")"), w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
