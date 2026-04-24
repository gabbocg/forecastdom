#' Conditional Superior Predictive Ability (CSPA) Test
#'
#' Tests the null hypothesis that a benchmark forecasting method has
#' conditional superior predictive ability over competing alternatives,
#' uniformly across all conditioning states. Based on Li, Liao, and
#' Quaedvlieg (2022).
#'
#' @param Y An \code{n x J} matrix of loss differentials with respect to the
#'   benchmark. Positive values indicate the benchmark outperforms competitor
#'   \code{j} in period \code{t}.
#' @param X An \code{n x 1} numeric vector of the conditioning variable.
#' @param level Significance level (e.g., 0.05).
#' @param trim Trim observations where the conditioning variable exceeds this
#'   many standard deviations from the mean. Use \code{0} (default) for no
#'   trimming.
#' @param prewhiten Order of pre-whitening VAR for HAC estimation. Use
#'   \code{0} for standard Newey-West, or \code{-1} (default) for AIC-based
#'   lag selection.
#' @param preselect Logical; perform adaptive inequality selection? Default
#'   \code{TRUE}.
#' @param R Integer; number of bootstrap replications for critical value
#'   computation. Default \code{10000}.
#'
#' @return A list with class \code{"cspa_test"} containing:
#'   \item{theta}{Infimum of the upper confidence bound. Negative values
#'     lead to rejection of the null.}
#'   \item{pvalue}{P-value for the test.}
#'   \item{reject}{Logical; whether the null is rejected at the given level.}
#'   \item{level}{Significance level used.}
#'   \item{h_hat}{Estimated conditional mean functions (\code{n x J} matrix).}
#'   \item{sigma_jx}{Estimated standard deviations (\code{J x n} matrix).}
#'   \item{kp}{Critical value from adaptive inequality selection.}
#'   \item{Vhat}{Logical matrix indicating selected (j, x) pairs.}
#'   \item{X}{Conditioning variable (after trimming).}
#'   \item{Y}{Loss differentials (after trimming).}
#'   \item{K}{Number of series terms used.}
#'   \item{prewhiten_order}{Pre-whitening lag order actually used.}
#'
#' @references
#' Li, J., Liao, Z., and Quaedvlieg, R. (2022). Conditional Superior
#' Predictive Ability. \emph{Review of Economic Studies}, 89(2), 843-875.
#'
#' @examples
#' \dontrun{
#' sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
#' result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
#' print(result)
#' }
#'
#' @importFrom stats quantile rnorm var
#' @importFrom MASS mvrnorm
#' @export
cspa_test <- function(Y, X, level, trim = 0, prewhiten = -1L,
                      preselect = TRUE, R = 10000L) {
  Y <- as.matrix(Y)
  X <- as.numeric(X)

  if (length(X) != nrow(Y)) {
    stop("Y and X must have the same number of observations.")
  }
  if (NCOL(X) != 1 && !is.vector(X)) {
    stop("X must be a single conditioning variable (vector).")
  }

  # Trimming
  if (trim > 0) {
    mu_x <- mean(X)
    sd_x <- sqrt(var(X))
    keep <- which(X >= mu_x - trim * sd_x & X <= mu_x + trim * sd_x)
    X <- X[keep]
    Y <- Y[keep, , drop = FALSE]
  }

  n <- nrow(Y)
  J <- ncol(Y)

  K <- max(4L, floor(n^(1 / 5)))

  gamma_n <- 1 - 0.1 / log(n)

  # Rank-transform X and evaluate Legendre basis
  x_rank <- rank(X, ties.method = "min")
  P <- get_legendre(2 * x_rank / n - 1, K)

  # Series regression
  XX <- crossprod(P) / n
  XX_inv <- solve(XX)
  beta <- XX_inv %*% (crossprod(P, Y) / n)
  Qinv <- kronecker(diag(J), XX_inv)
  uhat <- Y - P %*% beta

  # Construct Pu = kron(ones(1,J), P) .* kron(uhat, ones(1,K))
  Pu <- matrix(0, nrow = n, ncol = K * J)
  for (j in seq_len(J)) {
    cols <- ((j - 1) * K + 1):(j * K)
    Pu[, cols] <- P * uhat[, j]
  }

  # HAC estimation
  if (prewhiten == 0L) {
    Omega <- Qinv %*% covnw(Pu) %*% Qinv
    pw_order <- 0L
  } else {
    pw <- do_prewhiten(Pu, prewhiten)
    Omega_pw <- covnw(pw$resid)
    Ip <- diag(ncol(Pu))
    for (p in seq_len(pw$pstar)) {
      rows <- ((p - 1) * ncol(Pu) + 1):(p * ncol(Pu))
      Ip <- Ip - pw$Phi[rows, ]
    }
    Omega_rc <- solve(t(Ip)) %*% Omega_pw %*% solve(Ip)
    Omega <- Qinv %*% Omega_rc %*% Qinv
    pw_order <- pw$pstar
  }

  # Matrix square root of Omega
  e <- eigen(Omega, symmetric = TRUE)
  e$values[e$values < 0] <- 0
  sqrtOmega <- e$vectors %*% diag(sqrt(e$values)) %*% t(e$vectors)

  # Estimated conditional means
  h_hat <- P %*% beta  # n x J

  # Simulate Gaussian process
  xi <- sqrtOmega %*% matrix(stats::rnorm(K * J * R), nrow = K * J, ncol = R)

  # Compute sigma_jx and supT
  # Matrix mult via BLAS, divide+colmax via C++
  sigma_jx <- matrix(0, nrow = J, ncol = n)
  supT <- matrix(0, nrow = J, ncol = R)

  for (j in seq_len(J)) {
    idx <- ((j - 1) * K + 1):(j * K)
    Omega_jj <- Omega[idx, idx]
    sigma_jx[j, ] <- sqrt(pmax(rowSums((P %*% Omega_jj) * P), 0))
    tstat_j <- P %*% xi[idx, , drop = FALSE]  # BLAS
    supT[j, ] <- divide_colmax_cpp(tstat_j, sigma_jx[j, ])
  }

  # Adaptive inequality selection (Step 2 of Algorithm 1)
  max_supT <- colmax_cpp(supT)
  K_n_bar <- stats::quantile(max_supT, gamma_n)

  min_envelope <- min(h_hat + K_n_bar * t(sigma_jx) / sqrt(n))
  Vhat <- matrix(FALSE, nrow = J, ncol = n)
  for (j in seq_len(J)) {
    Vhat[j, ] <- h_hat[, j] <= (min_envelope + 2 * K_n_bar * sigma_jx[j, ] / sqrt(n))
  }

  if (!preselect) {
    Vhat[] <- TRUE
  }

  # Compute critical value with selected set
  supT_ais <- matrix(0, nrow = J, ncol = R)
  for (j in seq_len(J)) {
    idx <- ((j - 1) * K + 1):(j * K)
    tstat_j <- P %*% xi[idx, , drop = FALSE]  # BLAS
    supT_ais[j, ] <- divide_colmax_selected_cpp(
      tstat_j, sigma_jx[j, ], Vhat[j, ]
    )
  }

  max_supT_ais <- colmax_cpp(supT_ais)
  kp <- stats::quantile(max_supT_ais, 1 - level)
  theta_p <- min(h_hat + kp * t(sigma_jx) / sqrt(n))

  # P-value computation (C++ binary search: O(log R) instead of O(R))
  sorted_max <- sort(max_supT_ais)
  pvalue <- pvalue_search_cpp(h_hat, t(sigma_jx), sorted_max, sqrt(n))

  result <- list(
    theta = theta_p,
    pvalue = pvalue,
    reject = theta_p < 0,
    level = level,
    h_hat = h_hat,
    sigma_jx = sigma_jx,
    kp = kp,
    Vhat = Vhat,
    X = X,
    Y = Y,
    K = K,
    prewhiten_order = pw_order
  )
  class(result) <- "cspa_test"
  result
}

#' Print Method for CSPA Test Results
#'
#' Displays a formatted summary of the CSPA test output, including the test
#' statistic (theta), p-value, decision, and key estimation details.
#'
#' @param x An object of class \code{"cspa_test"}, as returned by
#'   \code{\link{cspa_test}}.
#' @param digits Integer; number of decimal places for numeric output.
#'   Default \code{4}.
#' @param ... Additional arguments (currently ignored).
#'
#' @return Invisibly returns \code{x}.
#'
#' @examples
#' \dontrun{
#' sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
#' result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
#' print(result)
#' }
#'
#' @export
print.cspa_test <- function(x, digits = 4, ...) {
  n <- nrow(x$Y)
  J <- ncol(x$Y)
  decision <- if (x$reject) "Rejected" else "Not rejected"
  star <- if (x$reject) " ***" else ""

  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Conditional Superior Predictive Ability", w)
  .center_line("(Li, Liao, and Quaedvlieg, 2022)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  # Hypotheses
  .padded_line("H0: Benchmark weakly dominates all competitors", w)
  .padded_line("    conditionally, uniformly across all states", w)
  .padded_line("H1: Some competitor outperforms the benchmark", w)
  .padded_line("    in certain conditioning states", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  # Test results
  .padded_line("Test Results:", w)
  .kv_line("Theta", formatC(x$theta, digits = digits, format = "f"), w)
  .kv_line("P-value", formatC(x$pvalue, digits = digits, format = "f"), w)
  .kv_line("Significance level", formatC(x$level, digits = digits, format = "f"), w)
  .kv_line("Decision", paste0(decision, star), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  # Estimation details
  .padded_line("Estimation Details:", w)
  .kv_line("Observations (n)", n, w)
  .kv_line("Competitors (J)", J, w)
  .kv_line("Series terms (K)", x$K, w)
  pw_label <- if (x$prewhiten_order == 0) "0 (Newey-West)" else paste0(x$prewhiten_order, " (pre-whitened)")
  .kv_line("HAC lag order", pw_label, w)

  # Adaptive inequality selection summary
  n_selected <- sum(x$Vhat)
  n_total <- length(x$Vhat)
  pct <- round(100 * n_selected / n_total, 1)
  .kv_line("Selected (j,x) pairs", sprintf("%d / %d (%.1f%%)", n_selected, n_total, pct), w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
}

#' Summary Method for CSPA Test Results
#'
#' Provides a detailed summary of the CSPA test, including per-competitor
#' diagnostics of the estimated conditional mean functions.
#'
#' @param object An object of class \code{"cspa_test"}, as returned by
#'   \code{\link{cspa_test}}.
#' @param digits Integer; number of decimal places. Default \code{4}.
#' @param ... Additional arguments (currently ignored).
#'
#' @return Invisibly returns \code{object}.
#'
#' @examples
#' \dontrun{
#' sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
#' result <- cspa_test(sim$Y, sim$X, level = 0.05, trim = 2)
#' summary(result)
#' }
#'
#' @export
summary.cspa_test <- function(object, digits = 4, ...) {
  print(object, digits = digits)

  J <- ncol(object$Y)
  n <- nrow(object$Y)

  cat("Per-competitor diagnostics:\n\n")

  header <- sprintf("  %-12s %10s %10s %10s %10s",
                     "Competitor", "min h_j", "max h_j", "mean h_j", "Selected %")
  cat(header, "\n")
  cat("  ", paste(rep("-", nchar(header) - 2), collapse = ""), "\n", sep = "")

  for (j in seq_len(J)) {
    h_j <- object$h_hat[, j]
    sel_pct <- round(100 * sum(object$Vhat[j, ]) / n, 1)
    cat(sprintf("  %-12s %10s %10s %10s %9s%%\n",
                paste0("j = ", j),
                formatC(min(h_j), digits = digits, format = "f"),
                formatC(max(h_j), digits = digits, format = "f"),
                formatC(mean(h_j), digits = digits, format = "f"),
                formatC(sel_pct, format = "f", digits = 1)))
  }
  cat("\n")

  invisible(object)
}

# --- Internal formatting helpers ---

.center_line <- function(text, width) {
  pad <- max(0, (width - nchar(text)) %/% 2)
  cat("\u2502", strrep(" ", pad), text,
      strrep(" ", width - nchar(text) - pad), "\u2502\n", sep = "")
}

.padded_line <- function(text, width) {
  cat("\u2502 ", text, strrep(" ", max(0, width - nchar(text) - 1)),
      "\u2502\n", sep = "")
}

.kv_line <- function(key, value, width) {
  value <- as.character(value)
  content <- paste0("  ", key, ": ", value)
  cat("\u2502", content, strrep(" ", max(0, width - nchar(content))),
      "\u2502\n", sep = "")
}
