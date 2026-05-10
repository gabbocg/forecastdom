#' Uniform Multi-Horizon Superior Predictive Ability Test
#'
#' Tests the null hypothesis that a benchmark forecasting method has
#' \emph{uniform} (i.e. simultaneous, at every horizon) superior predictive
#' ability over a competitor in a multi-horizon setting, using Quaedvlieg's
#' (2021) moving-block-bootstrap implementation of the uniform SPA test
#' (\code{uSPA}).
#'
#' @param loss_diff A \code{T x H} matrix of loss differentials, defined as
#'   \code{L_bench - L_comp} at each horizon \code{h = 1, ..., H}. Positive
#'   values indicate the benchmark has higher loss (i.e. is worse) than the
#'   competitor at that horizon.
#' @param L Integer; moving-block-bootstrap block length.
#' @param B Integer; number of bootstrap replications. Default \code{999}.
#' @param level Significance level (e.g. \code{0.05}). Default \code{0.05}.
#'
#' @return A list with class \code{"uspa_mh_test"} containing:
#'   \item{statistic}{The uSPA test statistic
#'     \eqn{t = \min_h \sqrt{T}\,\bar d_h / \sqrt{\hat\omega_h}}.}
#'   \item{pvalue}{Moving-block bootstrap p-value
#'     \eqn{B^{-1}\sum_b \mathbf{1}\{t < t_b^*\}} (upper tail).}
#'   \item{reject}{Logical; whether the null is rejected at \code{level}.}
#'   \item{level}{Significance level used.}
#'   \item{L}{Block length used.}
#'   \item{B}{Number of bootstrap replications.}
#'   \item{T}{Number of time periods.}
#'   \item{H}{Number of forecast horizons.}
#'   \item{d_bar}{Sample mean of loss differentials at each horizon (length \code{H}).}
#'
#' @details
#' The uniform multi-horizon SPA test statistic is
#' \deqn{t^{uSPA} = \min_{1 \le h \le H}
#'   \frac{\sqrt{T}\, \bar d_h}{\sqrt{\hat\omega_h}},}
#' where \eqn{\bar d_h} is the sample mean of the loss differential
#' \code{L_bench - L_comp} at horizon \code{h}, and \eqn{\hat\omega_h} is its
#' Quadratic-Spectral HAC long-run variance estimate (Andrews, 1991).
#'
#' Critical values are obtained from a moving-block bootstrap that recenters
#' the loss differentials so the null is imposed (Quaedvlieg, 2021), with the
#' "natural variance" estimator recomputed within each bootstrap replication.
#' The resulting p-value is upper-tail: large positive values of the statistic
#' (i.e. the benchmark has higher loss \emph{uniformly} across horizons)
#' lead to rejection. Equivalently, rejection requires \eqn{\bar d_h > 0} at
#' every horizon; the test has limited power against alternatives where the
#' benchmark is worse at only some horizons.
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
#' set.seed(1)
#' ld <- matrix(rnorm(200 * 4, mean = 0.3), 200, 4)
#' uspa_mh_test(ld, L = 3, B = 199, level = 0.10)
#'
#' @export
uspa_mh_test <- function(loss_diff, L, B = 999L, level = 0.05) {

  ld <- as.matrix(loss_diff)
  T_ <- nrow(ld)
  H  <- ncol(ld)

  if (!is.numeric(L) || length(L) != 1L || L < 1L || L > T_) {
    stop("L must be a positive integer with L <= nrow(loss_diff).")
  }

  d_bar <- colMeans(ld)
  omega <- .qs_lrvar(ld)

  # uSPA statistic: minimum standardized horizon-wise mean
  t_uspa <- min(sqrt(T_) * d_bar / sqrt(omega))

  # Moving-block bootstrap with recentering under H0
  demeaned <- sweep(ld, 2, d_bar)
  t_boot <- numeric(B)
  for (b in seq_len(B)) {

    idx       <- .mbb_indices(T_, L)
    ld_b      <- demeaned[idx, , drop = FALSE]
    omega_b   <- .mbb_variance(ld_b, L)
    t_boot[b] <- min(sqrt(T_) * colMeans(ld_b) / sqrt(omega_b))

  }

  pvalue <- mean(t_uspa < t_boot)

  result <- list(
    statistic = t_uspa,
    pvalue    = pvalue,
    reject    = pvalue < level,
    level     = level,
    L         = as.integer(L),
    B         = as.integer(B),
    T         = T_,
    H         = H,
    d_bar     = d_bar
  )
  class(result) <- "uspa_mh_test"

  result

}

#' @export
print.uspa_mh_test <- function(x, digits = 4, ...) {

  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)
  decision <- if (x$reject) "Rejected ***" else "Not rejected"

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Uniform Multi-Horizon SPA Test", w)
  .center_line("(Quaedvlieg, 2021)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Benchmark has uSPA (weakly dominates)", w)
  .padded_line("H1: Benchmark uniformly worse than competitor", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("uSPA statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value (MBB)", formatC(x$pvalue, digits = digits, format = "f"), w)
  .kv_line("Decision", decision, w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (T)", x$T, w)
  .kv_line("Horizons (H)", x$H, w)
  .kv_line("Block length (L)", x$L, w)
  .kv_line("Bootstrap replications", x$B, w)
  .kv_line("Significance level", formatC(x$level, digits = digits, format = "f"), w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)

}
