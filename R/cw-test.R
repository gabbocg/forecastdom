#' Clark-West Test for Predictive Ability of Nested Models
#'
#' Tests whether an alternative (unrestricted) model has superior
#' out-of-sample predictive ability relative to a benchmark (restricted)
#' model, using the MSFE-adjusted statistic of Clark and West (2007).
#' Also computes the out-of-sample \eqn{R^2_{OS}}{R2OS} statistic.
#'
#' @param e1 Numeric vector of forecast errors from the benchmark
#'   (restricted/null) model.
#' @param e2 Numeric vector of forecast errors from the alternative
#'   (unrestricted) model.
#' @param f1 Numeric vector of forecasts from the benchmark model.
#' @param f2 Numeric vector of forecasts from the alternative model.
#' @param h Integer; forecast horizon. Default \code{1}.
#' @param nlag Non-negative integer; number of Newey-West lags. If
#'   \code{NULL} (default), uses \code{0} for \code{h = 1} and
#'   \code{floor(1.5 * h)} otherwise.
#'
#' @return A list with class \code{"cw_test"} containing:
#'   \item{statistic}{The Clark-West t-statistic.}
#'   \item{pvalue}{One-sided p-value (H1: alternative is better).}
#'   \item{r2os}{Out-of-sample \eqn{R^2_{OS}}{R2OS} in percent.}
#'   \item{n}{Number of observations.}
#'   \item{h}{Forecast horizon.}
#'   \item{nlag}{Number of Newey-West lags used.}
#'
#' @details
#' The MSFE-adjusted series is defined as:
#' \deqn{\hat{f}_t = e_{1,t}^2 - \left(e_{2,t}^2 - (f_{1,t} - f_{2,t})^2\right)}
#' The test regresses \eqn{\hat{f}_t} on a constant and uses the resulting
#' t-statistic, compared to a standard normal distribution (one-sided).
#'
#' The standard error is Newey-West (Bartlett weights, autocovariances
#' divided by \eqn{n}) with \code{nlag} lags. Overlapping \eqn{h}-step
#' forecasts make \eqn{\hat{f}_t} serially correlated up to lag
#' \eqn{h - 1}, which the least squares standard error ignores. The default
#' bandwidth of \eqn{1.5h} follows Clark and West (2007, Section 5); with
#' exactly \eqn{h - 1} lags the Bartlett weights shrink those
#' autocovariances and the test over-rejects. For \code{h = 1} the standard
#' error is the sample standard deviation over \eqn{\sqrt{n}}, which differs
#' from the least squares one by the factor \eqn{\sqrt{(n - 1)/n}}.
#'
#' @references
#' Clark, T.E. and West, K.D. (2007). Approximately Normal Tests for Equal
#' Predictive Accuracy in Nested Models. \emph{Journal of Econometrics},
#' 138(1), 291-311.
#'
#' @examples
#' set.seed(42)
#' n <- 200
#' actual <- rnorm(n)
#' f1 <- actual + rnorm(n, sd = 0.5)
#' f2 <- actual + rnorm(n, sd = 0.4)
#' e1 <- actual - f1
#' e2 <- actual - f2
#' cw_test(e1, e2, f1, f2)
#'
#' @importFrom stats pnorm
#' @export
cw_test <- function(e1, e2, f1, f2, h = 1L, nlag = NULL) {
  
  e1 <- as.numeric(e1)
  e2 <- as.numeric(e2)
  f1 <- as.numeric(f1)
  f2 <- as.numeric(f2)

  n <- length(e1)
  
  if (length(e2) != n || length(f1) != n || length(f2) != n) {
    
    stop("All inputs must have the same length.")
    
  }

  h <- .check_horizon(h, n)
  nlag <- .check_nlag(if (is.null(nlag)) .default_nlag(h) else nlag, n)

  # Out-of-sample R-squared
  r2os <- 100 * (1 - sum(e2 ^ 2) / sum(e1 ^ 2))

  # MSFE-adjusted series
  adj <- e1 ^ 2 - (e2 ^ 2 - (f1 - f2) ^ 2)

  # t-statistic of the mean, with a Newey-West standard error
  tstat <- mean(adj) / sqrt(covnw(adj, nlag = nlag)[1, 1] / n)

  # One-sided p-value (H1: alternative model is better, i.e. R2OS > 0)
  pval <- stats::pnorm(tstat, lower.tail = FALSE)

  result <- list(
    statistic = tstat,
    pvalue = pval,
    r2os = r2os,
    n = n,
    h = h,
    nlag = nlag
  )

  class(result) <- "cw_test"
  
  result
  
}

#' @export
print.cw_test <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Clark-West Test (2007)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Benchmark MSFE <= Alternative MSFE", w)
  .padded_line("H1: Alternative model is superior (R2OS > 0)", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("CW statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value (one-sided)", formatC(x$pvalue, digits = digits, format = "f"), w)
  .kv_line("R2OS (%)", formatC(x$r2os, digits = 2, format = "f"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (n)", x$n, w)
  .kv_line("Forecast horizon (h)", x$h, w)
  .kv_line("Newey-West lags", x$nlag, w)
  .kv_line("Reference distribution", "N(0,1)", w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
