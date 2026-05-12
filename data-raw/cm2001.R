# data-raw/cm2001.R
# Build data/cm2001.rda for the Clark & McCracken (2001, JoE) Section 5
# empirical illustration: monthly US unemployment and inflation from
# FRED.
#
# Run interactively: source("data-raw/cm2001.R")

dir.create("data-raw/cm2001", recursive = TRUE, showWarnings = FALSE)

unrate_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=UNRATE"
cpi_url    <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCSL"
unrate_path <- "data-raw/cm2001/unrate.csv"
cpi_path    <- "data-raw/cm2001/cpi.csv"
if (!file.exists(unrate_path)) utils::download.file(unrate_url, unrate_path, mode = "wb")
if (!file.exists(cpi_path))    utils::download.file(cpi_url,    cpi_path,    mode = "wb")

ur  <- read.csv(unrate_path); names(ur)  <- c("date", "unrate")
cpi <- read.csv(cpi_path);    names(cpi) <- c("date", "cpi")
ur$date  <- as.Date(ur$date)
cpi$date <- as.Date(cpi$date)

dat <- merge(ur, cpi, by = "date")
dat <- dat[order(dat$date), ]
# Annualised monthly log inflation, following CM (2001) eq. (5.1).
dat$infl <- c(NA, 1200 * log(dat$cpi[-1] / dat$cpi[-nrow(dat)]))
dat <- dat[!is.na(dat$infl), c("date", "unrate", "infl")]
rownames(dat) <- NULL

cm2001 <- dat
usethis::use_data(cm2001, overwrite = TRUE, compress = "xz")
cat("Saved data/cm2001.rda — n =", nrow(cm2001),
    "rows, range:", format(range(cm2001$date)), "\n")
