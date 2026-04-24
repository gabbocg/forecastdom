#' Simulate Data from the CSPA Paper DGP
#'
#' Generates data from the data generating process in Section 3.1 of Li,
#' Liao, and Quaedvlieg (2022). The conditioning variable \eqn{X_t} follows
#' a Gaussian AR(1) with coefficient 0.5, and the loss differentials are
#' \eqn{Y_{j,t} = 1 - a \exp(-(X_t - c)^2) + u_{j,t}}, where \eqn{u_{j,t}}
#' follows an AR(1) with coefficient \code{rho_u}.
#'
#' @param J Integer; number of competing forecast methods.
#' @param n Integer; sample size.
#' @param a Numeric; controls the shape of the conditional mean function.
#'   \code{a = 1} gives the null hypothesis (\eqn{h_j(c) = 0}).
#' @param c Numeric; location parameter for the minimum of \eqn{h_j(x)}.
#' @param rho_u Numeric in \eqn{[0, 1)}; AR(1) coefficient of the error
#'   process. Higher values induce more serial dependence.
#'
#' @return A list with components:
#'   \item{Y}{An \code{n x J} matrix of loss differentials.}
#'   \item{X}{A numeric vector of length \code{n}.}
#'
#' @examples
#' sim <- do_sim(J = 3, n = 250, a = 1, c = 0, rho_u = 0.4)
#' str(sim)
#'
#' @importFrom stats arima.sim rnorm
#' @export
do_sim <- function(J, n, a, c, rho_u) {
  
  # X_t: AR(1) with phi = 0.5, variance of innovations = 1 - 0.5^2 = 0.75
  X <- stats::arima.sim(model = list(ar = 0.5), n = n, sd = sqrt(1 - 0.5 ^ 2))
  
  X <- as.numeric(X)

  # u_{j,t}: AR(1) with phi = rho_u, innovation variance = 3(1 - rho_u^2)
  sigma_v <- sqrt(3 * (1 - rho_u ^ 2))
  u <- matrix(0, nrow = n, ncol = J)
  
  for (j in seq_len(J)) {
    
    u[, j] <- as.numeric(stats::arima.sim(model = list(ar = rho_u), n = n, sd = sigma_v))
    
  }

  # Y_{j,t} = 1 - a * exp(-(X_t - c)^2) + u_{j,t}
  signal <- 1 - a * exp(-(X - c) ^ 2)
  Y <- matrix(signal, nrow = n, ncol = J) + u

  list(Y = Y, X = X)
  
}
