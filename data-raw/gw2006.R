# data-raw/gw2006.R
# Build data/gw2006.rda from the Philadelphia Fed Survey of Professional
# Forecasters mean CPI inflation forecasts plus FRED CPIAUCSL.
#
# Run interactively: source("data-raw/gw2006.R")

dir.create("data-raw/gw2006", recursive = TRUE, showWarnings = FALSE)

spf_url  <- paste0("https://www.philadelphiafed.org/-/media/frbp/assets/",
                   "surveys-and-data/survey-of-professional-forecasters/",
                   "data-files/files/mean_cpi_level.xlsx")
fred_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCSL"

spf_path  <- "data-raw/gw2006/mean_cpi_level.xlsx"
fred_path <- "data-raw/gw2006/cpi_fred.csv"

if (!file.exists(spf_path))  utils::download.file(spf_url, spf_path, mode = "wb")
if (!file.exists(fred_path)) utils::download.file(fred_url, fred_path, mode = "wb")

# SPF: CPI1..CPI6 are mean forecasts of annualised QoQ CPI inflation
# at horizons h = 0, 1, 2, 3, 4, 5 quarters ahead.
spf <- readxl::read_excel(spf_path, sheet = 1)
for (c in c("CPI1","CPI2","CPI3","CPI4","CPI5","CPI6")) {
  spf[[c]] <- suppressWarnings(as.numeric(spf[[c]]))
}
spf <- subset(spf, !is.na(CPI2))

# Quarterly CPI = average of monthly CPI within the quarter.
cpi <- read.csv(fred_path)
names(cpi) <- c("date", "cpi")
cpi$date    <- as.Date(cpi$date)
cpi$year    <- as.integer(format(cpi$date, "%Y"))
cpi$quarter <- (as.integer(format(cpi$date, "%m")) - 1L) %/% 3L + 1L
qcpi <- aggregate(cpi$cpi,
                  by = list(year = cpi$year, quarter = cpi$quarter),
                  FUN = mean)
names(qcpi)[3] <- "cpi"
qcpi <- qcpi[order(qcpi$year, qcpi$quarter), ]
qcpi$infl <- c(NA, (qcpi$cpi[-1] / qcpi$cpi[-nrow(qcpi)])^4 - 1) * 100

# Build panel: row t holds the realised inflation in quarter t and
# the SPF forecasts of inflation in t made at survey dates t, t-1, ...
key <- function(y, q) y * 4L + q
qcpi$key <- key(qcpi$year, qcpi$quarter)
spf$key  <- key(spf$YEAR, spf$QUARTER)

# Realisations
out <- qcpi[, c("year", "quarter", "infl")]
names(out) <- c("year", "quarter", "infl")

# Forecasts: SPF row with survey-key K contains forecasts for the
# realisations at quarters K, K+1, ..., K+5 (h = 0..5). For each
# horizon, shift the survey key forward by h and merge into `out` on
# the realisation key.
out$key <- key(out$year, out$quarter)
for (h in 0:4) {
  src <- spf[, c("key", paste0("CPI", h + 1L))]
  src$key <- src$key + h
  names(src)[2] <- paste0("spf_h", h)
  out <- merge(out, src, by = "key", all.x = TRUE)
}
out <- out[order(out$year, out$quarter), ]
# Date stamp = first day of quarter's third month.
out$date <- as.Date(sprintf("%04d-%02d-01",
                            out$year, out$quarter * 3L))

# Keep only quarters with at least one SPF horizon available
has_spf <- !is.na(out$spf_h0) | !is.na(out$spf_h1) | !is.na(out$spf_h2)
out <- out[has_spf, ]
out$infl_lag <- c(NA, out$infl[-nrow(out)])

gw2006 <- data.frame(
  date     = out$date,
  year     = out$year,
  quarter  = out$quarter,
  infl     = out$infl,
  infl_lag = out$infl_lag,
  spf_h0   = out$spf_h0,
  spf_h1   = out$spf_h1,
  spf_h2   = out$spf_h2,
  spf_h3   = out$spf_h3,
  spf_h4   = out$spf_h4,
  stringsAsFactors = FALSE
)
rownames(gw2006) <- NULL

usethis::use_data(gw2006, overwrite = TRUE, compress = "xz")
cat("Saved data/gw2006.rda — n =", nrow(gw2006),
    "rows, range:", format(range(gw2006$date)), "\n")
