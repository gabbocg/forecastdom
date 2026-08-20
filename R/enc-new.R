#' Clark-McCracken ENC-NEW Encompassing Test
#'
#' Tests whether the benchmark model encompasses the alternative model,
#' using the ENC-NEW statistic of Clark and McCracken (2001). Under the
#' null, the benchmark forecast encompasses the alternative (no additional
#' information in the alternative).
#'
#' @param e1 Numeric vector of forecast errors from the benchmark model.
#' @param e2 Numeric vector of forecast errors from the alternative model.
#'
#' @return A list with class \code{"enc_new"} containing:
#'   \item{statistic}{The ENC-NEW test statistic.}
#'   \item{n}{Number of observations.}
#'
#' @details
#' The ENC-NEW statistic is:
#' \deqn{\text{ENC-NEW} = n \cdot \frac{\bar{c}}{\text{MSFE}_2}}
#' where \eqn{\bar{c} = n^{-1} \sum (e_{1,t}^2 - e_{2,t} e_{1,t})} and
#' \eqn{\text{MSFE}_2 = n^{-1} \sum e_{2,t}^2}.
#'
#' Critical values are non-standard and depend on the estimation setup.
#' See Clark and McCracken (2001, Table 2) for asymptotic critical values.
#'
#' @references
#' Clark, T.E. and McCracken, M.W. (2001). Tests of Equal Forecast Accuracy
#' and Encompassing for Nested Models. \emph{Journal of Econometrics},
#' 105(1), 85-110.
#'
#' @examples
#' set.seed(42)
#' e1 <- rnorm(100)
#' e2 <- rnorm(100, sd = 0.9)
#' enc_new(e1, e2)
#'
#' @export
enc_new <- function(e1, e2) {
  
  e1 <- as.numeric(e1)
  e2 <- as.numeric(e2)

  if (length(e1) != length(e2)) {
    
    stop("e1 and e2 must have the same length.")
    
  }

  n <- length(e1)

  c_bar <- mean(e1 ^ 2 - e2 * e1)
  msfe2 <- mean(e2 ^ 2)

  enc_stat <- n * c_bar / msfe2

  result <- list(statistic = enc_stat, n = n)
  class(result) <- "enc_new"
  
  result
  
}

#' @export
print.enc_new <- function(x, digits = 4, ...) {
  
  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("ENC-NEW Encompassing Test", w)
  .center_line("(Clark and McCracken, 2001)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: Benchmark encompasses the alternative", w)
  .padded_line("H1: Alternative adds predictive content", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("ENC-NEW statistic", formatC(x$statistic, digits = digits, format = "f"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (n)", x$n, w)
  .padded_line("Note: Critical values are non-standard.", w)
  .padded_line("See Clark & McCracken (2001, Table 2).", w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)
  
}
