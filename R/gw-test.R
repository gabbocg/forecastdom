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
#'   variables). Row \eqn{t} pairs with the loss differential \eqn{d_t} and
#'   must be known at that forecast's origin, \eqn{h} periods before
#'   \eqn{d_t} is observed. Column names, if any, label the instruments in
#'   error messages. If \code{NULL} (default), uses a constant and the loss
#'   differential lagged by \code{h}.
#' @param loss Character; loss function. \code{"SE"} for squared error
#'   (default), \code{"AE"} for absolute error.
#' @param h Integer; forecast horizon. Default \code{1}.
#' @param nlag Non-negative integer; number of Newey-West lags. If
#'   \code{NULL} (default), uses \code{0} for \code{h = 1} and
#'   \code{floor(1.5 * h)} otherwise.
#'
#' @return A list with class \code{"gw_test"} containing:
#'   \item{statistic}{The Wald test statistic.}
#'   \item{pvalue}{P-value from the chi-squared distribution.}
#'   \item{df}{Degrees of freedom (number of instruments).}
#'   \item{n}{Number of observations used.}
#'   \item{loss}{Loss function used.}
#'   \item{h}{Forecast horizon.}
#'   \item{nlag}{Number of Newey-West lags used.}
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
#' The covariance of \eqn{d_t W_t} is Newey-West (Bartlett weights,
#' demeaned, autocovariances divided by \eqn{n}) with \code{nlag} lags. For
#' \code{h = 1} the moments are a martingale difference under the null and
#' the sample covariance suffices (Giacomini and White, 2006, Theorem 1).
#' For \code{h > 1} they are serially correlated up to lag \eqn{h - 1}.
#' Giacomini and White's code uses \eqn{h - 1} lags, but Bartlett weights then
#' shrink those autocovariances and the test over-rejects, so the default is
#' the \eqn{1.5h} bandwidth of Clark and West (2007); \code{nlag = h - 1}
#' reproduces their code's choice.
#'
#' If the moment covariance is singular, the test stops and names the
#' instruments whose moments are collinear.
#'
#' @references
#' Giacomini, R. and White, H. (2006). Tests of Conditional Predictive
#' Ability. \emph{Econometrica}, 74(6), 1545-1578.
#'
#' Clark, T.E. and West, K.D. (2007). Approximately Normal Tests for Equal
#' Predictive Accuracy in Nested Models. \emph{Journal of Econometrics},
#' 138(1), 291-311.
#'
#' @examples
#' set.seed(42)
#' e1 <- rnorm(200)
#' e2 <- rnorm(200, sd = 0.9)
#' gw_test(e1, e2)
#'
#' @importFrom stats pchisq
#' @export
gw_test <- function(e1, e2, instruments = NULL, loss = c("SE", "AE"),
                    h = 1L, nlag = NULL) {
  
  loss <- match.arg(loss)
  e1 <- as.numeric(e1)
  e2 <- as.numeric(e2)

  if (length(e1) != length(e2)) {
    
    stop("e1 and e2 must have the same length.")
    
  }

  n_full <- length(e1)
  h <- .check_horizon(h, n_full)

  # Loss differentials
  if (loss == "SE") {
    
    d <- e1 ^ 2 - e2 ^ 2
    
  } else {
    
    d <- abs(e1) - abs(e2)
    
  }

  if (is.null(instruments)) {
    
    # Default: constant and the loss differential lagged by h, the last one
    # observed at the forecast origin
    W <- cbind(1, d[1:(n_full - h)])
    colnames(W) <- c("constant", "lagged loss differential")
    d <- d[(h + 1):n_full]
    n <- n_full - h
    
  } else {
    
    instruments <- as.matrix(instruments)
    
    if (nrow(instruments) != n_full) {
      
      stop("instruments must have the same number of rows as e1.")
      
    }
    
    W <- instruments
    unnamed <- if (is.null(colnames(W))) rep(TRUE, ncol(W)) else colnames(W) == ""
    colnames(W)[unnamed] <- paste("column", which(unnamed))
    n <- n_full
    
  }

  q <- ncol(W)
  nlag <- .check_nlag(if (is.null(nlag)) .default_nlag(h) else nlag, n)

  # Instrumented moments: d_t * W_t
  dW <- W * d  # n x q

  # Sample mean
  m_bar <- colMeans(dW)

  # HAC variance (Newey-West)
  Sigma <- covnw(dW, nlag = nlag) / n

  collinear <- .collinear_moments(Sigma, dW)

  if (length(collinear) > 0) {

    stop("The moment covariance is singular; these instruments have ",
         "collinear moments d_t * W_t: ",
         paste(colnames(W)[collinear], collapse = ", "), ".")

  }

  # Wald statistic
  wald <- as.numeric(t(m_bar) %*% solve(Sigma, m_bar))

  pval <- stats::pchisq(wald, df = q, lower.tail = FALSE)

  result <- list(statistic = wald, pvalue = pval, df = q, n = n, loss = loss,
                 h = h, nlag = nlag)
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
  .kv_line("Forecast horizon (h)", x$h, w)
  .kv_line("Newey-West lags", x$nlag, w)
  .kv_line("Loss function", x$loss, w)
  .kv_line("Reference distribution", paste0("Chi-sq(", x$df, ")"), w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}

# Columns of the moment matrix Z whose covariance S is singular: moments with
# no variation, or those loading on a null direction of the correlation matrix.
.collinear_moments <- function(S, Z) {

  tol <- sqrt(.Machine$double.eps)
  s <- sqrt(pmax(diag(S), 0))
  degenerate <- which(s <= tol * sqrt(colMeans(Z ^ 2)) / sqrt(nrow(Z)))

  if (length(degenerate) > 0) {

    return(degenerate)

  }

  ev <- eigen(S / outer(s, s), symmetric = TRUE)
  null <- ev$values < tol

  which(rowSums(abs(ev$vectors[, null, drop = FALSE])) > tol)

}
