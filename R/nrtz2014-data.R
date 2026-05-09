#' Equity Premium and Technical Indicators (Neely, Rapach, Tu, & Zhou, 2014)
#'
#' Monthly U.S. log equity premium (in percent) and the 14 binary
#' technical-indicator predictors of Neely, Rapach, Tu, and Zhou (2014),
#' "Forecasting the Equity Risk Premium: The Role of Technical
#' Indicators." The macroeconomic predictors of the same paper are
#' \emph{not} included; for those, see \link{rz2013}.
#'
#' Indicators are constructed from monthly S&P 500 closing prices and
#' trading volume (Goyal-Welch updated dataset) following the rules in
#' the paper:
#' \itemize{
#'   \item \strong{MA(s,l)} -- 1 if the \eqn{s}-month moving average of
#'     the price exceeds the \eqn{l}-month moving average, else 0.
#'   \item \strong{MOM(m)} -- 1 if today's price is at or above the price
#'     \eqn{m} months ago, else 0.
#'   \item \strong{VOL(s,l)} -- 1 if the \eqn{s}-month moving average of
#'     on-balance volume exceeds the \eqn{l}-month moving average, else 0.
#' }
#'
#' @format A data frame with 733 rows and 16 variables. Sample period is
#' 1950-12 to 2011-12 (monthly).
#' \describe{
#'   \item{date}{First-of-month \code{Date}.}
#'   \item{eq_prem}{Log equity premium, in percent:
#'     \eqn{100 \cdot [\log(1 + r_t) - \log(1 + rf_{t-1})]}.}
#'   \item{MA_1_9, MA_1_12, MA_2_9, MA_2_12, MA_3_9, MA_3_12}{Moving-average
#'     signals \code{MA(s,l)} for \eqn{s \in \{1,2,3\}}, \eqn{l \in \{9,12\}}.}
#'   \item{MOM_9, MOM_12}{Momentum signals \code{MOM(m)} for \eqn{m \in \{9,12\}}.}
#'   \item{VOL_1_9, VOL_1_12, VOL_2_9, VOL_2_12, VOL_3_9, VOL_3_12}{
#'     On-balance-volume signals \code{VOL(s,l)} for \eqn{s \in \{1,2,3\}},
#'     \eqn{l \in \{9,12\}}.}
#' }
#'
#' @source Replication archive of Neely et al. (2014):
#'   \url{https://github.com/GabboCg/nrtz2014}. The underlying price and
#'   volume data are from Amit Goyal's website
#'   (\url{http://www.hec.unil.ch/agoyal/}).
#'
#' @references
#' Neely, C. J., Rapach, D. E., Tu, J., and Zhou, G. (2014). Forecasting
#' the equity risk premium: The role of technical indicators.
#' \emph{Management Science}, 60(7), 1772-1791.
#'
#' @examples
#' data(nrtz2014)
#' head(nrtz2014)
#' # Fraction of months each technical indicator equals 1
#' colMeans(nrtz2014[, -(1:2)])
"nrtz2014"
