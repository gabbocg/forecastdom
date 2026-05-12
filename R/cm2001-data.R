#' US Unemployment and Inflation (Clark & McCracken, 2001 setup)
#'
#' Monthly US civilian unemployment rate and annualised monthly log
#' inflation rate, assembled from FRED series \code{UNRATE} and
#' \code{CPIAUCSL}. The series support the Phillips-curve forecasting
#' illustration in Clark and McCracken (2001, Section 5): does adding
#' lagged inflation to a univariate AR for unemployment improve
#' out-of-sample forecasts?
#'
#' @format A data frame with 937 rows and 3 columns:
#' \describe{
#'   \item{date}{First day of the month (\code{Date}).}
#'   \item{unrate}{Civilian unemployment rate (percent), FRED
#'     \code{UNRATE}.}
#'   \item{infl}{Annualised monthly log inflation, computed as
#'     \eqn{1200 \cdot \log(\text{CPI}_t / \text{CPI}_{t-1})} from
#'     FRED \code{CPIAUCSL}.}
#' }
#'
#' @source FRED, Federal Reserve Bank of St. Louis,
#'   \url{https://fred.stlouisfed.org/series/UNRATE} and
#'   \url{https://fred.stlouisfed.org/series/CPIAUCSL}.
#'
#' @references
#' Clark, T. E. and McCracken, M. W. (2001). Tests of equal forecast
#' accuracy and encompassing for nested models. \emph{Journal of
#' Econometrics}, 105(1), 85-110.
"cm2001"
