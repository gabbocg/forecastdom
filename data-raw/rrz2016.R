# =====================================================================
# data-raw/rrz2016.R
#
# Build the `rrz2016` exported dataset from the raw Goyal-Welch +
# short-interest spreadsheet used in Rapach, Ringgenberg, and Zhou
# (2016), "Short interest and aggregate stock returns," Journal of
# Financial Economics, 121(1), 46-65.
#
# Source file:
#   data-raw/PredictorData2016.xlsx
# Originally from:
#   https://github.com/GabboCg/rrz2016
#
# We keep only what is needed to replicate Table A2 of the online
# appendix (IVX-Wald and qLL tests):
#   - r:   log excess return on the S&P 500
#          r_t = log(1 + R_t) - log(1 + rf_{t-1})
#   - SII: standardised residuals from a linear regression of
#          log(EWSI) on a time trend (Rapach-Ringgenberg-Zhou's
#          short interest index, 1973:01-2014:12)
#
# Sample: 1973:01-2014:12 inclusive (504 monthly observations).
# =====================================================================

library(readxl)

DATA_FILE <- "data-raw/PredictorData2016.xlsx"

gw_raw <- read_excel(DATA_FILE, sheet = "GW variables")
for (col in names(gw_raw)) gw_raw[[col]] <- as.numeric(gw_raw[[col]])

# 1973:01 corresponds to data row 1225 in the spreadsheet
idx_start <- 1225L
idx_end   <- 1728L
T_full    <- idx_end - idx_start + 1L
stopifnot(T_full == 504L)

dates <- seq.Date(as.Date("1973-01-01"), by = "month", length.out = T_full)

Rfree_lag <- gw_raw$Rfree[(idx_start - 1):(idx_end - 1)]
R_SP500   <- gw_raw$CRSP_SPvw[idx_start:idx_end]
r         <- log(1 + R_SP500) - log(1 + Rfree_lag)

# Short-interest sheet: 504 monthly EWSI observations from 1973:01
si_raw   <- read_excel(DATA_FILE, sheet = "Short interest")
EWSI     <- as.numeric(si_raw[[2]][1:T_full])
log_EWSI <- log(EWSI)

trend      <- seq_len(T_full)
fit_linear <- lm(log_EWSI ~ trend)
SII        <- as.numeric(scale(residuals(fit_linear)))

rrz2016 <- data.frame(
  date = dates,
  r    = r,
  SII  = SII,
  row.names = NULL,
  stringsAsFactors = FALSE
)

stopifnot(!anyNA(rrz2016), nrow(rrz2016) == T_full)

save(rrz2016, file = "data/rrz2016.rda", compress = "bzip2")
