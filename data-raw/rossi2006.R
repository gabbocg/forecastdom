# =====================================================================
# data-raw/rossi2006.R
#
# Build the `rossi2006` exported dataset from the raw Datastream file
# used in Rossi (2006), "Are exchange rates really random walks? Some
# evidence robust to parameter instability," Macroeconomic Dynamics,
# 10(1), 20-38.
#
# Source file:
#   data-raw/PredictorData1998.txt
# Originally from:
#   https://github.com/gabbocg/rossi2006
#
# The raw file is 310 monthly rows (1973:03 to 1998:12) by 29 unlabelled
# columns. The replication script (table_1.R) only uses the five
# nominal bilateral exchange rates vs. the U.S. dollar, located at
# columns 8, 13, 18, 23, and 28 (Canada, France, Germany, Italy, Japan).
# We keep just those five series in long form.
# =====================================================================

raw <- as.matrix(
  read.table(
    "data-raw/PredictorData1998.txt",
    header = FALSE
  )
)

stopifnot(nrow(raw) == 310L, ncol(raw) == 29L)

fx_cols    <- c(8L, 13L, 18L, 23L, 28L)
countries  <- c("Canada", "France", "Germany", "Italy", "Japan")
dates      <- seq.Date(as.Date("1973-03-01"), by = "month", length.out = 310L)

rossi2006 <- data.frame(
  date    = rep(dates, times = length(fx_cols)),
  country = factor(rep(countries, each = nrow(raw)), levels = countries),
  fx      = as.numeric(raw[, fx_cols]),
  stringsAsFactors = FALSE
)

save(rossi2006, file = "data/rossi2006.rda", compress = "bzip2")
