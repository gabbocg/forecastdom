# Shared internal helpers for the pairwise tests (dm_test, cw_test, gw_test).

# Forecast horizon h as an integer, checked against the n forecast errors.
.check_horizon <- function(h, n) {

  if (!is.numeric(h) || length(h) != 1L || is.na(h) || h < 1 || h != round(h)) {

    stop("h must be a single positive integer.")

  }

  if (h >= n) {

    stop("h must be smaller than the number of forecast errors (", n, ").")

  }

  as.integer(h)

}

# Newey-West lag count for h-step forecasts. One-step losses are a
# martingale difference under the null, so the sample variance suffices.
# For h > 1 the moments are MA(h - 1); Bartlett weights with only h - 1 lags
# shrink those autocovariances by 1 - j/h and over-reject, so the bandwidth
# is 1.5h, as in Clark and West (2007, Section 5).
.default_nlag <- function(h) {

  if (h == 1L) 0L else as.integer(floor(1.5 * h))

}

# Newey-West lag count as an integer, checked against the n observations.
.check_nlag <- function(nlag, n) {

  if (!is.numeric(nlag) || length(nlag) != 1L || is.na(nlag) || nlag < 0 ||
      nlag != round(nlag) || nlag >= n) {

    stop("nlag must be a non-negative integer smaller than the number of ",
         "observations (", n, ").")

  }

  as.integer(nlag)

}
