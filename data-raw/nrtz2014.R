# =====================================================================
# data-raw/nrtz2014.R
#
# Build the `nrtz2014` exported dataset from the raw Goyal-Welch
# spreadsheet used in Neely, Rapach, Tu, and Zhou (2014), "Forecasting
# the Equity Risk Premium: The Role of Technical Indicators,"
# Management Science, Vol. 60(7), pp. 1772-1791.
#
# Source file:
#   data-raw/PredictorData2014.xls   (Goyal-Welch updated)
# Originally from:
#   https://github.com/GabboCg/nrtz2014
#
# We keep only the dependent variable (log equity premium) and the 14
# technical-indicator predictors built from S&P 500 prices and volume:
#   MA(s,l)  for (s,l) in {(1,9),(1,12),(2,9),(2,12),(3,9),(3,12)}
#   MOM(m)   for m in {9, 12}
#   VOL(s,l) for (s,l) in {(1,9),(1,12),(2,9),(2,12),(3,9),(3,12)}
#
# Sample: 1950-12 to 2011-12 inclusive (733 monthly observations).
# Indicator construction follows the replication script in
# https://github.com/GabboCg/nrtz2014/blob/main/load.R
# =====================================================================

library(readxl)

raw <- read_excel("data-raw/PredictorData2014.xls", sheet = "Monthly")

# Row range: 1927:01 - 2011:12 (1020 obs); volume series begins 1950:01.
r1 <- 673L
r2 <- 1692L
n_full <- r2 - r1 + 1L
stopifnot(n_full == 1020L)

dates_full <- seq.Date(as.Date("1927-01-01"), as.Date("2011-12-01"), by = "month")
stopifnot(length(dates_full) == n_full)

# --- Equity premium (percent, log) ---
mkt_ret  <- as.numeric(raw[[16]][r1:r2])
rf_lag   <- as.numeric(raw[[11]][(r1 - 1):(r2 - 1)])
y_log    <- 100 * (log(1 + mkt_ret) - log(1 + rf_lag))
y_simple <- mkt_ret - rf_lag

# --- S&P 500 prices and volume ---
SP500   <- as.numeric(raw[[2]][r1:r2])

idx_vol_start <- 949L                                # 1950:01
volume_data   <- as.numeric(raw[[18]][idx_vol_start:r2])
prices_vol    <- as.numeric(raw[[2]][idx_vol_start:r2])

# --- Indicator builders (verbatim from upstream load.R) ---
compute_ma <- function(prices, s, l) {
  n <- length(prices)
  signal <- rep(NA_real_, n)
  for (t in l:n) {
    ma_short  <- mean(prices[(t - s + 1):t])
    ma_long   <- mean(prices[(t - l + 1):t])
    signal[t] <- as.integer(ma_short > ma_long)
  }
  signal
}

compute_mom <- function(prices, m) {
  n <- length(prices)
  signal <- rep(NA_real_, n)
  for (t in (m + 1):n) signal[t] <- as.integer(prices[t] >= prices[t - m])
  signal
}

compute_vol <- function(prices, volume, s, l) {
  n <- length(prices)
  obv <- numeric(n)
  obv[1] <- 0
  for (t in 2:n) {
    obv[t] <- obv[t - 1] + ifelse(prices[t] >= prices[t - 1], volume[t], -volume[t])
  }
  signal <- rep(NA_real_, n)
  for (t in l:n) {
    ma_short  <- mean(obv[(t - s + 1):t])
    ma_long   <- mean(obv[(t - l + 1):t])
    signal[t] <- as.integer(ma_short > ma_long)
  }
  signal
}

# --- MA and MOM signals over full 1927:01-2011:12 ---
MA_1_9   <- compute_ma(SP500, 1, 9)
MA_1_12  <- compute_ma(SP500, 1, 12)
MA_2_9   <- compute_ma(SP500, 2, 9)
MA_2_12  <- compute_ma(SP500, 2, 12)
MA_3_9   <- compute_ma(SP500, 3, 9)
MA_3_12  <- compute_ma(SP500, 3, 12)
MOM_9    <- compute_mom(SP500, 9)
MOM_12   <- compute_mom(SP500, 12)

# --- VOL signals over volume-period series ---
VOL_1_9  <- compute_vol(prices_vol, volume_data, 1, 9)
VOL_1_12 <- compute_vol(prices_vol, volume_data, 1, 12)
VOL_2_9  <- compute_vol(prices_vol, volume_data, 2, 9)
VOL_2_12 <- compute_vol(prices_vol, volume_data, 2, 12)
VOL_3_9  <- compute_vol(prices_vol, volume_data, 3, 9)
VOL_3_12 <- compute_vol(prices_vol, volume_data, 3, 12)

# --- Trim to 1950:12 - 2011:12 (733 obs) ---
idx_1950_12 <- which(format(dates_full, "%Y-%m") == "1950-12")
idx_2011_12 <- which(format(dates_full, "%Y-%m") == "2011-12")
sample_idx  <- idx_1950_12:idx_2011_12
stopifnot(length(sample_idx) == 733L)

# VOL series starts at 1950:01: 1950:12 is index 12, last index is length(volume_data).
vol_sample_idx <- 12L:length(volume_data)
stopifnot(length(vol_sample_idx) == 733L)

nrtz2014 <- data.frame(
  date     = dates_full[sample_idx],
  eq_prem  = y_log[sample_idx],
  MA_1_9   = MA_1_9[sample_idx],
  MA_1_12  = MA_1_12[sample_idx],
  MA_2_9   = MA_2_9[sample_idx],
  MA_2_12  = MA_2_12[sample_idx],
  MA_3_9   = MA_3_9[sample_idx],
  MA_3_12  = MA_3_12[sample_idx],
  MOM_9    = MOM_9[sample_idx],
  MOM_12   = MOM_12[sample_idx],
  VOL_1_9  = VOL_1_9[vol_sample_idx],
  VOL_1_12 = VOL_1_12[vol_sample_idx],
  VOL_2_9  = VOL_2_9[vol_sample_idx],
  VOL_2_12 = VOL_2_12[vol_sample_idx],
  VOL_3_9  = VOL_3_9[vol_sample_idx],
  VOL_3_12 = VOL_3_12[vol_sample_idx],
  row.names = NULL,
  stringsAsFactors = FALSE
)

stopifnot(!anyNA(nrtz2014))
stopifnot(nrow(nrtz2014) == 733L, ncol(nrtz2014) == 16L)

save(nrtz2014, file = "data/nrtz2014.rda", compress = "bzip2")
