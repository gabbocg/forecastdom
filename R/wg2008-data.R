#' Welch & Goyal (2008) Annual Equity-Premium Dataset
#'
#' Annual equity premium and predictor series built from Welch and
#' Goyal's original \code{PredictorData.xls} (annual sheet) — the
#' data vintage shipped with the published 2008 paper. The equity
#' premium is constructed as the log total return on the S&P 500
#' minus the log risk-free rate (per WG Section 1), and the log
#' dividend-price ratio is
#' \eqn{\log(D12_{t-1}) - \log(\text{Index}_{t-1})}.
#'
#' @format A data frame with 134 rows and 13 columns covering
#' 1872-2005:
#' \describe{
#'   \item{year}{Calendar year.}
#'   \item{Index}{S&P 500 price level.}
#'   \item{D12}{Twelve-month moving sum of dividends.}
#'   \item{E12}{Twelve-month moving sum of earnings.}
#'   \item{Rfree}{Risk-free rate (decimal).}
#'   \item{tbl}{Treasury-bill yield.}
#'   \item{infl}{CPI inflation rate.}
#'   \item{ntis}{Net equity expansion.}
#'   \item{spret}{Total return on the S&P 500,
#'     \eqn{(P_t + D_t)/P_{t-1} - 1}.}
#'   \item{logeqp}{Log equity premium,
#'     \eqn{\log(1 + \text{spret}_t) - \log(1 + \text{Rfree}_t)}.}
#'   \item{log_dp_lag}{Lagged log dividend-price ratio,
#'     \eqn{\log(D12_{t-1}/\text{Index}_{t-1})} — the predictor used
#'     in WG Table 1.}
#'   \item{log_ep_lag}{Lagged log earnings-price ratio.}
#'   \item{log_de_lag}{Lagged log dividend-payout ratio.}
#' }
#'
#' @source Welch and Goyal (2008) original annual data file
#'   \code{PredictorData.xls}, distributed with the paper. A
#'   regularly updated version is maintained on Amit Goyal's
#'   website, \url{https://sites.google.com/view/agoyal145}.
#'
#' @references
#' Welch, I. and Goyal, A. (2008). A comprehensive look at the
#' empirical performance of equity premium prediction. \emph{Review of
#' Financial Studies}, 21(4), 1455-1508.
"wg2008"
