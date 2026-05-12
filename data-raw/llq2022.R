# data-raw/llq2022.R
# Build data/llq2022.rda (SP500) and data/llq2022_jnj.rda (JNJ) from the
# Li, Liao & Quaedvlieg (2022, REStud) replication package on Zenodo.
#
# Run interactively: source("data-raw/llq2022.R")
#
# Downloads ~40 MB on first run; cached under data-raw/llq2022/.

zip_url <- paste0(
  "https://zenodo.org/records/4884813/files/",
  "Replication_Package_CSPA_REStud.zip?download=1"
)
zip_path <- "data-raw/llq2022/cspa_zenodo.zip"
ext_dir  <- "data-raw/llq2022"

if (!file.exists(zip_path)) {
  dir.create(ext_dir, recursive = TRUE, showWarnings = FALSE)
  utils::download.file(zip_url, zip_path, mode = "wb")
}
if (!dir.exists(file.path(ext_dir, "Replication_Code"))) {
  utils::unzip(zip_path, exdir = ext_dir)
}

base <- file.path(ext_dir, "Replication_Code/Empirics_Volatility")
vx   <- readxl::read_excel(file.path(base, "Data_RV/VIX.xlsx"), sheet = 1)
vx$date <- as.Date(as.character(vx$Date), "%Y%m%d")
vix_close <- setNames(vx[["VIX Close"]], as.character(vx$date))

build_panel <- function(ticker) {
  rv <- readxl::read_excel(
    file.path(base, "Data_RV", paste0(ticker, "_RV_5min.xlsx")),
    sheet = 1
  )
  fc <- readxl::read_excel(
    file.path(base, "Forecasts",
              paste0("Combined_Forecasts_", ticker, ".xlsx")),
    sheet = 1
  )
  rv$date   <- as.Date(as.character(rv$Date), "%Y%m%d")
  oos_idx   <- (nrow(rv) - nrow(fc) + 1):nrow(rv)
  oos_dates <- rv$date[oos_idx]
  stopifnot(max(abs(rv$RV[oos_idx] - fc$True)) < 1e-10)

  in_vix     <- as.character(oos_dates) %in% names(vix_close)
  keep_dates <- oos_dates[in_vix]
  fc_keep    <- fc[in_vix, ]
  vix_keep   <- vix_close[as.character(keep_dates)]
  vix_lag    <- c(NA, vix_keep[-length(vix_keep)])

  out <- data.frame(
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
  )
  out <- out[-1, , drop = FALSE]
  rownames(out) <- NULL
  out
}

llq2022     <- build_panel("SP500")
llq2022_jnj <- build_panel("JNJ")

usethis::use_data(llq2022,     overwrite = TRUE, compress = "xz")
usethis::use_data(llq2022_jnj, overwrite = TRUE, compress = "xz")
