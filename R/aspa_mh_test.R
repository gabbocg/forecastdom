#' Average Multi-Horizon Superior Predictive Ability Test
#'
#' Implements the average multi-horizon SPA test of Quaedvlieg (2021), which
#' tests whether a weighted average of horizon-wise expected loss differentials
#' favors the benchmark, allowing inferior performance at some horizons to be
#' compensated by superior performance at others. Bootstrap follows
#' Algorithm 1 (moving-block bootstrap, block length \code{L}).
#'
#' @param loss_diff A \code{T x H} matrix of loss differentials, defined as
#'   \code{L_bench - L_comp} at each horizon. Positive values indicate the
#'   benchmark has higher loss (i.e. is worse) than the competitor.
#' @param weights Numeric vector of length \code{H} of horizon weights. They
#'   need not sum to 1; uniform weights \code{rep(1/H, H)} reproduce the
#'   unweighted average SPA of the original paper.
#' @param L Integer block length for the moving-block bootstrap.
#' @param B Integer number of bootstrap replications. Default \code{999}.
#' @param level Significance level. Default \code{0.05}.
#'
#' @return A list with class \code{"aspa_mh_test"} containing
#'   \code{statistic}, \code{pvalue}, \code{reject}, \code{level},
#'   \code{L}, \code{B}, \code{T}, \code{H}, \code{weights}, \code{d_bar}.
#'
#' @details
#' The aSPA statistic is
#' \deqn{t^{aSPA} = \sqrt{T}\, \bar d^w / \sqrt{\hat\omega^{QS}(\bar d^w)},}
#' where \eqn{d^w_t = \sum_h w_h d_{h,t}} and \eqn{\hat\omega^{QS}} is the
#' Quadratic-Spectral HAC long-run variance (Andrews, 1991). Critical values
#' are obtained via a moving-block bootstrap that recenters the weighted
#' series under the null. The p-value is upper-tail
#' (\code{mean(t < t_b)}); rejection requires the weighted-average
#' differential to be large and positive (the benchmark loses on the
#' weighted average).
#'
#' This is a port of the Matlab reference implementation accompanying
#' Quaedvlieg (2021); the helpers \code{.mbb_indices}, \code{.mbb_variance},
#' and \code{.qs_lrvar} translate \code{Get_MBB_ID.m}, \code{MBB_Variance.m},
#' and \code{QS.m} respectively.
#'
#' @references
#' Quaedvlieg, R. (2021). Multi-Horizon Forecast Comparison.
#' \emph{Journal of Business & Economic Statistics}, 39(1), 40-53.
#'
#' @examples
#' set.seed(2)
#' ld <- matrix(rnorm(200 * 4, mean = 0.2), 200, 4)
#' aspa_mh_test(ld, weights = rep(0.25, 4), L = 3, B = 199)
#'
#' @seealso \code{\link{uspa_mh_test}}, \code{\link{spa_test}}
#' @export
aspa_mh_test <- function(loss_diff, weights, L, B = 999L, level = 0.05) {

  loss_diff <- as.matrix(loss_diff)
  T_ <- nrow(loss_diff)
  H  <- ncol(loss_diff)

  if (length(weights) != H) {
    stop("length(weights) must equal ncol(loss_diff) (number of horizons).")
  }
  if (!is.numeric(L) || length(L) != 1L || L < 1L || L > T_) {
    stop("L must be a positive integer with L <= nrow(loss_diff).")
  }

  weighted_ld <- as.matrix(loss_diff %*% weights)        # T x 1
  d_bar       <- mean(weighted_ld)
  omega       <- .qs_lrvar(weighted_ld)                  # length 1
  t_aspa      <- sqrt(T_) * d_bar / sqrt(omega)

  demeaned <- weighted_ld - d_bar
  t_boot   <- numeric(B)
  for (b in seq_len(B)) {

    idx        <- .mbb_indices(T_, L)
    z          <- demeaned[idx, , drop = FALSE]
    omega_b    <- .mbb_variance(z, L)
    t_boot[b]  <- sqrt(T_) * mean(z) / sqrt(omega_b)

  }

  pvalue <- mean(t_aspa < t_boot)

  result <- list(
    statistic = as.numeric(t_aspa), pvalue = pvalue,
    reject = pvalue < level, level = level,
    L = as.integer(L), B = as.integer(B), T = T_, H = H,
    weights = as.numeric(weights), d_bar = as.numeric(d_bar)
  )
  class(result) <- "aspa_mh_test"
  result

}

#' @export
print.aspa_mh_test <- function(x, digits = 4, ...) {

  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)
  decision <- if (x$reject) "Rejected ***" else "Not rejected"

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Average Multi-Horizon SPA Test", w)
  .center_line("(Quaedvlieg, 2021)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Benchmark has aSPA (weighted avg superior)", w)
  .padded_line("H1: Benchmark worse on weighted average", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("aSPA statistic",  formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value (MBB)",   formatC(x$pvalue,    digits = digits, format = "f"), w)
  .kv_line("Decision",        decision, w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (T)",      x$T, w)
  .kv_line("Horizons (H)",          x$H, w)
  .kv_line("Block length (L)",      x$L, w)
  .kv_line("Bootstrap replications", x$B, w)
  .kv_line("Significance level",    formatC(x$level, digits = digits, format = "f"), w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")
  invisible(x)

}
