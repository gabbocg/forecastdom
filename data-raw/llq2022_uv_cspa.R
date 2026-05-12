# data-raw/llq2022_uv_cspa.R
# Reproduce Table_UV_CSPA.xlsx from the LLQ (2022) replication package.
# For each of the 28 stocks, run pairwise CSPA tests across the six
# forecasting models and tally rejections at the 5% level.
#
# Run interactively: source("data-raw/llq2022_uv_cspa.R")
# Requires data-raw/llq2022.R to have been run first (or the unzipped
# replication package present at data-raw/llq2022/Replication_Code).

devtools::load_all(quiet = TRUE)

base    <- "data-raw/llq2022/Replication_Code/Empirics_Volatility"
results <- file.path(base, "Results")
tickers <- c("SP500", "AXP", "BA", "CAT", "CSCO", "CVX", "DD", "DIS",
             "GE", "HD", "IBM", "INTC", "JNJ", "JPM", "KO", "MCD",
             "MMM", "MRK", "MSFT", "NKE", "PFE", "PG", "TRV", "UNH",
             "UTX", "VZ", "WMT", "XOM")
models  <- c("AR1", "AR22", "AR22_Lasso", "HAR", "HARQ", "ARFIMA")
N <- length(models)

# Load VIX once (shared across tickers).
vx <- readxl::read_excel(file.path(base, "Data_RV/VIX.xlsx"), sheet = 1)
vx$date  <- as.Date(as.character(vx$Date), "%Y%m%d")
vix_idx  <- setNames(vx[["VIX Close"]], as.character(vx$date))

build_panel <- function(ticker) {
  rv_path <- file.path(base, "Data_RV", paste0(ticker, "_RV_5min.xlsx"))
  fc_path <- file.path(base, "Forecasts",
                       paste0("Combined_Forecasts_", ticker, ".xlsx"))
  rv <- readxl::read_excel(rv_path, sheet = 1)
  fc <- readxl::read_excel(fc_path, sheet = 1)
  rv$date <- as.Date(as.character(rv$Date), "%Y%m%d")
  oos_idx   <- (nrow(rv) - nrow(fc) + 1):nrow(rv)
  oos_dates <- rv$date[oos_idx]
  in_vix <- as.character(oos_dates) %in% names(vix_idx)
  keep_dates <- oos_dates[in_vix]
  fc_keep    <- fc[in_vix, ]
  vix_keep   <- vix_idx[as.character(keep_dates)]
  vix_lag    <- c(NA, vix_keep[-length(vix_keep)])
  data.frame(
    date       = keep_dates,
    rv         = fc_keep$True,
    AR1        = fc_keep$AR1,
    AR22       = fc_keep$AR22,
    AR22_Lasso = fc_keep[["AR22 Lasso"]],
    HAR        = fc_keep$HAR,
    HARQ       = fc_keep$HARQ,
    ARFIMA     = fc_keep$ARFIMA,
    vix_lag    = vix_lag,
    stringsAsFactors = FALSE
  )[-1, , drop = FALSE]
}

qlike <- function(f, y) (f / y) - log(f / y) - 1

# rejs_array[stock, k, l] = TRUE if benchmark l fails to dominate alternative k
rejs <- array(NA, dim = c(length(tickers), N, N),
              dimnames = list(tickers, models, models))
losses_mean <- matrix(NA_real_, nrow = length(tickers), ncol = N,
                      dimnames = list(tickers, models))

t_start <- Sys.time()
for (i in seq_along(tickers)) {
  tk   <- tickers[i]
  pnl  <- build_panel(tk)
  loss <- sapply(models, function(m) qlike(pnl[[m]], pnl$rv))
  losses_mean[i, ] <- colMeans(loss)
  X <- pnl$vix_lag

  for (k in seq_len(N)) {       # alternative
    for (l in seq_len(N)) {     # benchmark
      if (k == l) next
      Y <- as.matrix(loss[, k] - loss[, l])
      set.seed(1000L * i + 10L * k + l)
      r <- cspa_test(Y, X, level = 0.05, trim = 0,
                     prewhiten = -1L, preselect = TRUE, R = 10000L)
      rejs[i, k, l] <- isTRUE(r$reject)
    }
  }
  cat(sprintf("  [%2d/%d] %-6s done (%5.1f s elapsed)\n",
              i, length(tickers), tk,
              as.numeric(Sys.time() - t_start, units = "secs")))
}

# Aggregate to 6x6 count: cell (k, l) = # stocks rejecting "l dominates k"
mine <- apply(rejs, c(2, 3), sum)
diag(mine) <- NA

# Published table (from Table_UV_CSPA.xlsx).
# File layout: first column is a row index; remaining columns hold the
# 6x6 count matrix with "#N/A" on the diagonal (Ox `savemat` writes
# the header row as Var1..Var6).
paper_raw <- suppressMessages(readxl::read_excel(
  file.path(results, "Table_UV_CSPA.xlsx"), sheet = 1
))
paper <- as.matrix(paper_raw[, -1])
storage.mode(paper) <- "numeric"  # "#N/A" cells become NA
dimnames(paper) <- list(models, models)

llq2022_uv_cspa <- list(
  mine    = mine,
  paper   = paper,
  losses  = losses_mean,
  tickers = tickers,
  models  = models,
  level   = 0.05,
  R       = 1000L
)

usethis::use_data(llq2022_uv_cspa, overwrite = TRUE, compress = "xz")
cat("Total time:",
    round(as.numeric(Sys.time() - t_start, units = "secs"), 1),
    "s\n")
