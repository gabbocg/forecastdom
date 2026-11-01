#' Unconditional Superior Predictive Ability (USPA/SPA) Test
#'
#' Tests the null hypothesis that a benchmark forecasting method has
#' unconditional superior predictive ability over all competing alternatives,
#' using Hansen's (2005) stationary bootstrap approach.
#'
#' @param Y An \code{n x J} matrix of loss differentials with respect to the
#'   benchmark. Positive values indicate the benchmark outperforms competitor
#'   \code{j} in period \code{t}.
#' @param level Significance level (e.g., 0.05).
#' @param B Integer; number of bootstrap replications. Default \code{5000}.
#' @param q Numeric in \eqn{(0, 1)}; parameter for the geometric distribution
#'   in the stationary bootstrap. Controls the average block length
#'   (\eqn{1/q}). Default \code{0.25} (average block length of 4).
#'
#' @return A list with class \code{"spa_test"} containing:
#'   \item{statistic}{The SPA test statistic (consistent).}
#'   \item{pvalue}{Bootstrap p-value.}
#'   \item{reject}{Logical; whether the null is rejected.}
#'   \item{level}{Significance level used.}
#'   \item{d_bar}{Sample mean of loss differentials for each competitor.}
#'   \item{n}{Number of observations.}
#'   \item{J}{Number of competitors.}
#'   \item{B}{Number of bootstrap replications.}
#'
#' @details
#' Let \eqn{d_{j,t} = -Y_{j,t}}, so that positive values mean competitor
#' \code{j} beats the benchmark. The SPA test statistic is:
#' \deqn{T^{SPA} = \max\left(\max_{1 \le j \le J}
#'   \frac{\sqrt{n}\, \bar{d}_j}{\hat{\omega}_j}, 0\right)}
#' where \eqn{\bar{d}_j} is the sample mean of \eqn{d_{j,t}} and
#' \eqn{\hat{\omega}_j^2} is its Newey-West long-run variance.
#'
#' The null hypothesis is rejected when the benchmark is not superior to all
#' competitors, i.e., some competitor significantly outperforms it.
#'
#' The bootstrap distribution uses Hansen's (2005) consistent recentring:
#' competitors with \eqn{\sqrt{n}\, \bar{d}_j / \hat{\omega}_j <
#' -\sqrt{2 \log \log n}} are treated as clearly inferior and recentred at
#' zero instead of \eqn{\bar{d}_j}, so they do not inflate the critical value.
#'
#' @references
#' Hansen, P.R. (2005). A Test for Superior Predictive Ability.
#' \emph{Journal of Business & Economic Statistics}, 23(4), 365-380.
#'
#' White, H. (2000). A Reality Check for Data Snooping.
#' \emph{Econometrica}, 68(5), 1097-1126.
#'
#' @examples
#' \donttest{
#' sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
#' spa_test(sim$Y, level = 0.05, B = 500)
#' }
#'
#' @importFrom stats rnorm runif var
#' @export
spa_test <- function(Y, level, B = 5000L, q = 0.25) {

  Y <- as.matrix(Y)
  n <- nrow(Y)
  J <- ncol(Y)

  # Hansen's (2005) d_j = L_0 - L_j: positive when competitor j beats the benchmark
  d <- -Y
  d_bar <- colMeans(d)

  # Newey-West long-run standard deviation of each d_j
  nlag <- floor(1.2 * n ^ (1 / 3))
  omega <- vapply(seq_len(J), function(j) sqrt(covnw(d[, j, drop = FALSE], nlag = nlag)), numeric(1))

  t_j <- sqrt(n) * d_bar / omega
  t_stat <- max(t_j, 0)

  # Consistent recentring: clearly inferior competitors are centred at zero
  mu_c <- d_bar * (t_j >= -sqrt(2 * log(log(n))))

  # Stationary bootstrap
  boot_stats <- numeric(B)
  for (b in seq_len(B)) {

    idx <- .stationary_bootstrap_indices(n, q)
    z_bar <- colMeans(d[idx, , drop = FALSE]) - mu_c
    boot_stats[b] <- max(sqrt(n) * z_bar / omega, 0)

  }

  pval <- mean(boot_stats >= t_stat)

  result <- list(statistic = t_stat, pvalue = pval, reject = pval < level, level = level, d_bar = colMeans(Y), n = n, J = J, B = B)
  class(result) <- "spa_test"

  result

}

#' @export
print.spa_test <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)
  decision <- if (x$reject) "Rejected ***" else "Not rejected"

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Superior Predictive Ability Test", w)
  .center_line("(Hansen, 2005)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Benchmark is superior to all competitors", w)
  .padded_line("H1: Some competitor outperforms the benchmark", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("SPA statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value (bootstrap)", formatC(x$pvalue, digits = digits, format = "f"), w)
  .kv_line("Decision", decision, w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (n)", x$n, w)
  .kv_line("Competitors (J)", x$J, w)
  .kv_line("Bootstrap replications", x$B, w)
  .kv_line("Significance level", formatC(x$level, digits = digits, format = "f"), w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}

# Stationary bootstrap index generator (Politis and Romano, 1994)
.stationary_bootstrap_indices <- function(n, q) {
  
  idx <- integer(n)
  idx[1] <- sample.int(n, 1)
  u <- stats::runif(n)
  
  for (t in 2:n) {
    
    if (u[t] < q) {
      
      idx[t] <- sample.int(n, 1)
      
    } else {
      
      idx[t] <- if (idx[t - 1] < n) idx[t - 1] + 1L else 1L
      
    }
    
  }
  
  idx
  
}
