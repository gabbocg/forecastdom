# data-raw/wg2008.R
# Build data/wg2008.rda from Welch and Goyal's original PredictorData.xls
# (annual sheet) — the vintage shipped with WG (2008, RFS). The third
# sheet of the workbook holds the annual series.
#
# Run interactively: source("data-raw/wg2008.R")

xls_path <- "data-raw/wg2008/PredictorData.xls"
stopifnot(file.exists(xls_path))

raw <- readxl::read_excel(xls_path, sheet = "Annual")

# Many columns are read as character because they encode NaN as "NaN";
# coerce the ones we need.
num <- function(z) suppressWarnings(as.numeric(z))
raw$Index <- num(raw$Index)
raw$D12   <- num(raw$D12)
raw$E12   <- num(raw$E12)
raw$Rfree <- num(raw$Rfree)
raw$tbl   <- num(raw$tbl)
raw$infl  <- num(raw$infl)
raw$lty   <- num(raw$lty)
raw$ntis  <- num(raw$ntis)

raw <- raw[order(raw$yyyy), ]
lag1 <- function(z) c(NA, z[-length(z)])

# Equity premium = log(1 + total stock return) - log(1 + Rfree),
# following WG's construction. Total return is (P + D)/P_{lag} - 1.
spret  <- (raw$Index + raw$D12) / lag1(raw$Index) - 1
logeqp <- log(1 + spret) - log(1 + raw$Rfree)

# Predictors in the form used in WG Table 1 (Section 1).
log_dp_lag <- lag1(log(raw$D12) - log(raw$Index))
log_ep_lag <- lag1(log(raw$E12) - log(raw$Index))
log_de_lag <- lag1(log(raw$D12) - log(raw$E12))

wg2008 <- data.frame(
  year        = raw$yyyy,
  Index       = raw$Index,
  D12         = raw$D12,
  E12         = raw$E12,
  Rfree       = raw$Rfree,
  tbl         = raw$tbl,
  infl        = raw$infl,
  ntis        = raw$ntis,
  spret       = spret,
  logeqp      = logeqp,
  log_dp_lag  = log_dp_lag,
  log_ep_lag  = log_ep_lag,
  log_de_lag  = log_de_lag,
  stringsAsFactors = FALSE
)

# Restrict to rows where the equity premium and log d/p are defined
# (loses the very first row to the lag).
wg2008 <- subset(wg2008, !is.na(logeqp) & !is.na(log_dp_lag))
rownames(wg2008) <- NULL

usethis::use_data(wg2008, overwrite = TRUE, compress = "xz")
cat("Saved data/wg2008.rda — n =", nrow(wg2008),
    " rows, range:", range(wg2008$year), "\n")
