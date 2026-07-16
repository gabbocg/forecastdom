#' Confidence Set for the Most Superior (CSMS) Forecasting Method
#'
#' Constructs the confidence set for the most superior forecasting method
#' by inverting the CSPA test, as described in Section 2.3 of Li, Liao, and
#' Quaedvlieg (2022). The set contains all methods \code{j} for which the
#' CSPA null hypothesis (with \code{j} as benchmark) is not rejected.
#'
#' @param losses An \code{n x (J+1)} matrix where each column contains the
#'   loss series for a forecasting method. All methods are treated
#'   symmetrically (no pre-specified benchmark).
#' @param X An \code{n x 1} numeric vector of the conditioning variable.
#' @param level Significance level (e.g., 0.05).
#' @param trim Trimming parameter (standard deviations). Default \code{0}.
#' @param prewhiten Pre-whitening order. Default \code{-1} (AIC).
#' @param preselect Logical; adaptive inequality selection. Default
#'   \code{TRUE}.
#' @param R Integer; Gaussian process replications. Default \code{10000}.
#' @param method_names Optional character vector of method names. If
#'   \code{NULL}, uses \code{"M1", "M2", ...}.
#'
#' @return A list with class \code{"csms"} containing:
#'   \item{in_set}{Logical vector; which methods are in the confidence set.}
#'   \item{set_members}{Names of methods in the confidence set.}
#'   \item{theta}{Theta values for each method as benchmark.}
#'   \item{pvalues}{P-values for each method as benchmark.}
#'   \item{method_names}{Names of all methods.}
#'   \item{level}{Significance level.}
#'   \item{n_methods}{Total number of methods.}
#'
#' @details
#' For each method \code{j} in \code{0, ..., J}, the CSPA test is applied
#' with \code{j} as the benchmark. The confidence set is:
#' \deqn{\widehat{\mathcal{M}}_{n,1-\alpha} = \{0 \le j \le J :
#'   \text{CSPA test with } j \text{ as benchmark does not reject}\}}
#'
#' @references
#' Li, J., Liao, Z., and Quaedvlieg, R. (2022). Conditional Superior
#' Predictive Ability. \emph{Review of Economic Studies}, 89(2), 843-875.
#'
#' @examples
#' \donttest{
#' set.seed(42)
#' n <- 300
#' X <- arima.sim(list(ar = 0.5), n = n, sd = sqrt(0.75))
#' losses <- matrix(rnorm(n * 4), n, 4)
#' csms(losses, X, level = 0.05, trim = 2, R = 500L)
#' }
#'
#' @export
csms <- function(losses, X, level, trim = 0, prewhiten = -1L, preselect = TRUE, R = 10000L, method_names = NULL) {
  
  losses <- as.matrix(losses)
  X <- as.numeric(X)
  n <- nrow(losses)
  n_methods <- ncol(losses)

  if (is.null(method_names)) {
    
    method_names <- paste0("M", seq_len(n_methods))
    
  }
  
  if (length(method_names) != n_methods) {
    
    stop("method_names must have length equal to the number of columns in losses.")
    
  }

  theta_vals <- numeric(n_methods)
  pvalues <- numeric(n_methods)
  in_set <- logical(n_methods)

  for (j in seq_len(n_methods)) {
    
    # Loss differentials: Y_{k,t} = L_k - L_j (positive = j is better)
    competitors <- setdiff(seq_len(n_methods), j)
    Y_j <- losses[, competitors, drop = FALSE] - losses[, j]

    res <- tryCatch(
      cspa_test(Y_j, X, level = level, trim = trim,
                prewhiten = prewhiten, preselect = preselect, R = R),
      error = function(e) list(theta = NA, pvalue = NA, reject = TRUE)
    )

    theta_vals[j] <- res$theta
    pvalues[j] <- res$pvalue
    in_set[j] <- !res$reject
    
  }

  result <- list(
    in_set = in_set,
    set_members = method_names[in_set],
    theta = theta_vals,
    pvalues = pvalues,
    method_names = method_names,
    level = level,
    n_methods = n_methods
  )
  
  class(result) <- "csms"
  
  result
  
}

#' @export
print.csms <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("Confidence Set for the Most Superior (CSMS)", w)
  .center_line("(Li, Liao, and Quaedvlieg, 2022)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  pct <- formatC(100 * (1 - x$level), format = "f", digits = 0)
  .padded_line(paste0(pct, "% Confidence Set: {",
                      paste(x$set_members, collapse = ", "), "}"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Per-method CSPA results:", w)
  .padded_line("", w)

  cat(sprintf("\u2502  %-14s  %10s  %10s  %7s   \u2502\n",
              "Method", "Theta", "P-value", "In Set?"))
  cat("\u2502  ", strrep("-", w - 4), "  \u2502\n", sep = "")

  for (j in seq_len(x$n_methods)) {

    mark <- if (x$in_set[j]) "Yes" else "No"
    cat(sprintf("\u2502  %-14s  %10s  %10s  %7s   \u2502\n",
                x$method_names[j],
                formatC(x$theta[j], digits = digits, format = "f"),
                formatC(x$pvalues[j], digits = digits, format = "f"),
                mark))

  }

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
