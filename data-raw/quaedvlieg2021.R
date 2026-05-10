# data-raw/quaedvlieg2021.R
# Run interactively:  source("data-raw/quaedvlieg2021.R")
mat <- R.matlab::readMat("~/Downloads/Matlab/Example_Data.mat")
quaedvlieg2021 <- list(
  uspa = unname(as.matrix(mat$LossDiff.uSPA)),
  aspa = unname(as.matrix(mat$LossDiff.aSPA))
)
stopifnot(ncol(quaedvlieg2021$uspa) == 20L,
          ncol(quaedvlieg2021$aspa) == 20L)
usethis::use_data(quaedvlieg2021, overwrite = TRUE)
