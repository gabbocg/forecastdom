# data-raw/hl2005.R
# Build data/hl2005.rda from the Hansen & Lunde (2005, JAE) replication
# archive: IBM 5-min realized variance and 330 GARCH-family forecasts.
#
# Run interactively: source("data-raw/hl2005.R")

base_url <- "http://qed.econ.queensu.ca/jae/2005-v20.7/hansen-lunde"
dir.create("data-raw/hl2005", recursive = TRUE, showWarnings = FALSE)

for (f in c("yibm_data.mat", "yhatibm_data.mat", "readme.hl.txt")) {
  path <- file.path("data-raw/hl2005", f)
  if (!file.exists(path)) {
    utils::download.file(file.path(base_url, sub("yibm", "yibm",
                                                 sub("yhatibm", "yhatibm", f))),
                         path, mode = "wb")
  }
}

# ASCII matrix files have one header line giving "nrow ncol".
proxies_raw   <- as.matrix(read.table("data-raw/hl2005/yibm_data.mat",
                                      skip = 1))
forecasts_raw <- as.matrix(read.table("data-raw/hl2005/yhatibm_data.mat",
                                      skip = 1))

# Common date column (YYYYMMDD).
stopifnot(all(proxies_raw[, 1] == forecasts_raw[, 1]))
date <- as.Date(as.character(proxies_raw[, 1]), "%Y%m%d")

# Drop date; keep the 8 realised-variance proxies and 330 forecasts.
rv_proxies <- proxies_raw[, -1, drop = FALSE]
forecasts  <- forecasts_raw[, -1, drop = FALSE]

# Per the README, the 5-min linear-interpolation RV proxy is the
# headline series the paper uses for the main results. The README
# lists 7 proxies but the data file contains 8 columns; the first
# extra column is squared close-to-close returns (matching the
# DM/Dollar file convention). The RV proxies, in order:
proxy_names <- c(
  "sq_ccr",            # 1: squared close-to-close return
  "spline_50_3min",    # 2: Spline-50, 3 min sampling
  "spline_250_2min",   # 3: Spline-250, 2 min sampling
  "fourier_M85",       # 4: Fourier, M = 85
  "linear_5min",       # 5: Linear interpolation, 5 min  <- primary
  "prevtick_5min",     # 6: Previous tick, 5 min
  "linear_1min",       # 7: Linear interpolation, 1 min
  "prevtick_1min"      # 8: Previous tick, 1 min
)
colnames(rv_proxies) <- proxy_names

# 330 forecasts indexed by base model (55) x mean-error spec (6 groups,
# of sizes 55, 55, 55, 45, 55, 65 per the README). The benchmark
# GARCH(1,1) with constant mean and Gaussian errors is the 2nd base
# model in the 2nd group, i.e. column 56 + 2 = 57.
GARCH11_IDX <- 57L

# Sanity: the GARCH(1,1) column should produce non-zero, positive
# variance forecasts.
stopifnot(all(forecasts[, GARCH11_IDX] > 0))

hl2005 <- list(
  date         = date,
  rv           = rv_proxies[, "linear_5min"],
  rv_proxies   = rv_proxies,
  forecasts    = forecasts,
  garch11_idx  = GARCH11_IDX
)

usethis::use_data(hl2005, overwrite = TRUE, compress = "xz")
cat("Saved data/hl2005.rda — size:",
    file.size("data/hl2005.rda"), "bytes\n")
