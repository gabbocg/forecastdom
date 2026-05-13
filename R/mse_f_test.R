#' McCracken MSE-F Test for Equal Forecast Accuracy
#'
#' Tests the null hypothesis of equal mean squared forecast error
#' between the (restricted) benchmark and the (unrestricted) alternative
#' nested model, using the MSE-F statistic of McCracken (2007).
#' Under the null, the alternative does not reduce MSFE relative to
#' the benchmark.
#'
#' @param e1 Numeric vector of forecast errors from the benchmark
#'   (restricted) model.
#' @param e2 Numeric vector of forecast errors from the alternative
#'   (unrestricted) model.
#' @param h Integer; forecast horizon. Default \code{1}.
#'
#' @return A list with class \code{"mse_f_test"} containing:
#'   \item{statistic}{The MSE-F test statistic.}
#'   \item{msfe1}{Mean squared forecast error of the benchmark.}
#'   \item{msfe2}{Mean squared forecast error of the alternative.}
#'   \item{n}{Number of out-of-sample observations.}
#'   \item{h}{Forecast horizon.}
#'
#' @details
#' The MSE-F statistic is:
#' \deqn{\text{MSE-F} = (T - h + 1) \cdot \frac{\text{MSFE}_1 - \text{MSFE}_2}{\text{MSFE}_2}}
#' where \eqn{T} is the number of out-of-sample observations and
#' \eqn{h} is the forecast horizon.
#'
#' Critical values are non-standard and depend on the number of extra
#' regressors in the alternative model (\eqn{k_2}) and on
#' \eqn{\pi = P/R} (out-of-sample size relative to estimation
#' window). See McCracken (2007, Table 1) for asymptotic critical
#' values.
#'
#' @references
#' McCracken, M.W. (2007). Asymptotics for out of sample tests of
#' Granger causality. \emph{Journal of Econometrics}, 140(2), 719-752.
#'
#' Clark, T.E. and McCracken, M.W. (2001). Tests of Equal Forecast
#' Accuracy and Encompassing for Nested Models. \emph{Journal of
#' Econometrics}, 105(1), 85-110.
#'
#' @examples
#' set.seed(42)
#' e1 <- rnorm(100)
#' e2 <- rnorm(100, sd = 0.9)
#' mse_f_test(e1, e2)
#'
#' @export
mse_f_test <- function(e1, e2, h = 1L) {

  e1 <- as.numeric(e1)
  e2 <- as.numeric(e2)

  if (length(e1) != length(e2)) {

    stop("e1 and e2 must have the same length.")

  }

  n <- length(e1)
  h <- as.integer(h)

  if (h < 1L || h > n) {

    stop("h must be a positive integer no larger than length(e1).")

  }

  msfe1 <- mean(e1 ^ 2)
  msfe2 <- mean(e2 ^ 2)

  stat  <- (n - h + 1L) * (msfe1 - msfe2) / msfe2

  result <- list(statistic = stat,
                 msfe1     = msfe1,
                 msfe2     = msfe2,
                 n         = n,
                 h         = h)
  class(result) <- "mse_f_test"

  result

}

#' @export
print.mse_f_test <- function(x, digits = 4, ...) {

  w <- 52
  dash <- strrep("\u2500", w)
  dot  <- strrep("\u2504", w)

  cat("\n")
  cat("\u256D", dash, "\u256E\n", sep = "")
  .center_line("MSE-F Test for Equal Forecast Accuracy", w)
  .center_line("(McCracken, 2007)", w)
  cat("\u251C", dash, "\u2524\n", sep = "")

  .padded_line("H0: MSFE benchmark <= MSFE alternative", w)
  .padded_line("H1: Alternative reduces MSFE", w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Test Results:", w)
  .kv_line("MSE-F statistic",
           formatC(x$statistic, digits = digits, format = "f"), w)
  .kv_line("MSFE benchmark",
           formatC(x$msfe1,     digits = digits, format = "f"), w)
  .kv_line("MSFE alternative",
           formatC(x$msfe2,     digits = digits, format = "f"), w)
  cat("\u251C", dot, "\u2524\n", sep = "")

  .padded_line("Details:", w)
  .kv_line("Observations (n)", x$n, w)
  .kv_line("Forecast horizon (h)", x$h, w)
  .padded_line("Note: Critical values are non-standard.", w)
  .padded_line("See McCracken (2007, Table 1).", w)

  cat("\u2570", dash, "\u256F\n", sep = "")
  cat("\n")

  invisible(x)

}
