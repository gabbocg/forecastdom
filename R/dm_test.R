#' Diebold-Mariano Test for Equal Predictive Ability
#'
#' Tests the null hypothesis that two forecasting methods have equal
#' predictive ability (UEPA), with an optional small-sample correction
#' by Harvey, Leybourne, and Newbold (1997).
#'
#' @param e1 Numeric vector of forecast errors from model 1 (benchmark).
#' @param e2 Numeric vector of forecast errors from model 2 (competitor).
#' @param h Integer; forecast horizon. Default \code{1}.
#' @param loss Character; loss function to use. \code{"SE"} for squared error
#'   (default), \code{"AE"} for absolute error.
#' @param alternative Character; alternative hypothesis. \code{"two.sided"}
#'   (default), \code{"less"} (model 2 is better), or \code{"greater"}
#'   (model 1 is better).
#' @param correction Logical; apply the Harvey, Leybourne, and Newbold (1997)
#'   finite-sample correction? Default \code{TRUE}.
#'
#' @return A list with class \code{"dm_test"} containing:
#'   \item{statistic}{The (possibly corrected) DM test statistic.}
#'   \item{pvalue}{P-value.}
#'   \item{alternative}{The alternative hypothesis used.}
#'   \item{correction}{Whether HLN correction was applied.}
#'   \item{h}{Forecast horizon.}
#'   \item{n}{Number of observations.}
#'   \item{loss}{Loss function used.}
#'
#' @references
#' Diebold, F.X. and Mariano, R.S. (1995). Comparing Predictive Accuracy.
#' \emph{Journal of Business & Economic Statistics}, 13(3), 253-263.
#'
#' Harvey, D., Leybourne, S., and Newbold, P. (1997). Testing the Equality
#' of Prediction Mean Squared Errors. \emph{International Journal of
#' Forecasting}, 13(2), 281-291.
#'
#' @examples
#' set.seed(42)
#' e1 <- rnorm(100)
#' e2 <- rnorm(100, mean = 0.1)
#' dm_test(e1, e2)
#'
#' @importFrom stats pnorm pt var
#' @export
dm_test <- function(e1, e2, h = 1L, loss = c("SE", "AE"),
                    alternative = c("two.sided", "less", "greater"),
                    correction = TRUE) {
  
  loss <- match.arg(loss)
  alternative <- match.arg(alternative)
  e1 <- as.numeric(e1)
  e2 <- as.numeric(e2)

  if (length(e1) != length(e2)) {
    
    stop("e1 and e2 must have the same length.")
    
  }

  n <- length(e1)

  # Loss differentials
  if (loss == "SE") {
    
    d <- e1 ^ 2 - e2 ^ 2
    
  } else {
    
    d <- abs(e1) - abs(e2)
    
  }

  d_bar <- mean(d)

  # Long-run variance using Newey-West with h-1 lags
  gamma_0 <- stats::var(d)
  
  if (h > 1) {
    
    gamma_k <- sapply(1:(h - 1), function(k) {
      
      mean((d[(k + 1):n] - d_bar) * (d[1:(n - k)] - d_bar))
      
    })
    
    V_d <- (gamma_0 + 2 * sum(gamma_k)) / n
    
  } else {
    
    V_d <- gamma_0 / n
    
  }

  dm_stat <- d_bar / sqrt(V_d)

  if (correction) {
    
    # HLN (1997) correction factor
    hln_factor <- sqrt((n + 1 - 2 * h + h * (h - 1) / n) / n)
    dm_stat <- hln_factor * dm_stat
    # Use t-distribution with n-1 degrees of freedom
    pval <- switch(alternative,
      "two.sided" = 2 * stats::pt(-abs(dm_stat), df = n - 1),
      "less"      = stats::pt(dm_stat, df = n - 1),
      "greater"   = stats::pt(dm_stat, df = n - 1, lower.tail = FALSE)
    )
    
  } else {
    
    pval <- switch(alternative,
      "two.sided" = 2 * stats::pnorm(-abs(dm_stat)),
      "less"      = stats::pnorm(dm_stat),
      "greater"   = stats::pnorm(dm_stat, lower.tail = FALSE)
    )
    
  }

  result <- list(
    statistic = dm_stat,
    pvalue = pval,
    alternative = alternative,
    correction = correction,
    h = h,
    n = n,
    loss = loss
  )
  
  class(result) <- "dm_test"
  
  result
  
}

#' @export
print.dm_test <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  label <- if (x$correction) "Modified Diebold-Mariano Test (HLN, 1997)" else "Diebold-Mariano Test (1995)"

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line(label, w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  alt_text <- switch(x$alternative,
    "two.sided" = "H1: Methods have different predictive ability",
    "less"      = "H1: Model 2 has superior predictive ability",
    "greater"   = "H1: Model 1 has superior predictive ability"
  )
  .padded_line("H0: Equal predictive ability", w)
  .padded_line(alt_text, w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("DM statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("P-value", formatC(x$pvalue, digits = digits, format = "f"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (n)", x$n, w)
  .kv_line("Forecast horizon (h)", x$h, w)
  .kv_line("Loss function", x$loss, w)
  dist_label <- if (x$correction) paste0("t(", x$n - 1, ")") else "N(0,1)"
  .kv_line("Reference distribution", dist_label, w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
