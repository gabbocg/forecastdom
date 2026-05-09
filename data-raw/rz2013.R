# =====================================================================
# data-raw/rz2013.R
#
# Build the `rz2013` exported dataset from the prepared object in the
# replication archive of Rapach and Zhou (2013), "Forecasting Stock
# Returns," Handbook of Economic Forecasting, Vol. 2A, Chapter 6.
#
# Source file:
#   data-raw/rz2013_data.rds
# Originally from:
#   https://github.com/GabboCg/rz2013
#
# The .rds is a list with several pre-built data frames. We keep
# `data_log`: the log equity premium and the 14 Goyal-Welch macro
# predictors used for R-squared-OS evaluation. Dates are reconstructed
# (the original list dropped them after na.omit). Sample runs from
# 1926:12 to 2010:12 inclusive (1009 monthly observations).
# =====================================================================

bundle <- readRDS("data-raw/rz2013_data.rds")
data_log <- bundle$data_log

stopifnot(nrow(data_log) == 1009L, ncol(data_log) == 15L)

dates <- seq.Date(as.Date("1926-12-01"), by = "month", length.out = nrow(data_log))

rz2013 <- data.frame(
  date = dates,
  data_log,
  row.names = NULL,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

save(rz2013, file = "data/rz2013.rda", compress = "bzip2")
