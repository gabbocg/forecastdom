#' Plot CSPA Test Results
#'
#' Visualizes the estimated conditional mean functions \eqn{\hat{h}_j(x)},
#' their lower envelope, and the confidence bound from the CSPA test.
#'
#' @param object A \code{cspa_test} object returned by \code{\link{cspa_test}},
#'   or omitted if \code{Y} and \code{X} are provided directly.
#' @param Y An \code{n x J} matrix of loss differentials. Ignored if
#'   \code{object} is provided.
#' @param X An \code{n x 1} numeric vector of the conditioning variable.
#'   Ignored if \code{object} is provided.
#' @param level Significance level (e.g., 0.05). Ignored if \code{object}
#'   is provided.
#' @param trim Trimming parameter. Default \code{0}.
#' @param prewhiten Pre-whitening order. Default \code{-1}.
#' @param preselect Logical; adaptive inequality selection. Default
#'   \code{TRUE}.
#' @param ylab Label for the y-axis. Default \code{"Loss Difference"}.
#' @param xlab Label for the x-axis. Default \code{"Conditioning Variable"}.
#'
#' @return A \code{ggplot} object.
#'
#' @importFrom ggplot2 ggplot aes geom_line labs theme_minimal
#'   scale_color_manual scale_linetype_manual scale_linewidth_manual
#' @importFrom grDevices hcl.colors
#' @importFrom stats setNames
#' @export
cspa_test_plot <- function(object = NULL, Y = NULL, X = NULL, level = 0.05,
                           trim = 0, prewhiten = -1L, preselect = TRUE,
                           ylab = "Loss Difference",
                           xlab = "Conditioning Variable") {
  
  if (is.null(object)) {
    
    if (is.null(Y) || is.null(X)) {
      
      stop("Provide either a cspa_test object or Y and X.")
      
    }
    
    object <- cspa_test(Y, X, level = level, trim = trim, prewhiten = prewhiten, preselect = preselect)
    
  }

  h_hat <- object$h_hat
  sigma_jx <- object$sigma_jx
  kp <- object$kp
  X <- object$X
  n <- length(X)
  J <- ncol(h_hat)

  # Sort by X. Both h_hat (rows) and sigma_jx (columns) are stored in
  # original X order, so the upper-bound matrix must be built in
  # original order and then sorted as a single object.
  ord <- order(X)
  X_sorted <- X[ord]
  h_sorted <- h_hat[ord, , drop = FALSE]
  upper_sorted <- (h_hat + kp * t(sigma_jx) / sqrt(n))[ord, , drop = FALSE]

  lower_envelope <- apply(h_sorted, 1, min)
  CI_sorted      <- apply(upper_sorted, 1, min)

  # When J = 1 the lower envelope coincides with the single h_1, so the
  # colored h_j layer is redundant and the envelope label is misleading;
  # collapse to "Loss Differential" + "Confidence Bound" only.
  single <- J == 1L
  env_label <- if (single) "Loss Differential" else "Lower Envelope"

  df_env <- data.frame(x = X_sorted, y = lower_envelope, type = env_label)
  df_ci  <- data.frame(x = X_sorted, y = CI_sorted,      type = "Confidence Bound")

  if (single) {
    df_all <- rbind(df_env, df_ci)
    type_levels <- c(env_label, "Confidence Bound")
    df_all$type <- factor(df_all$type, levels = type_levels)
    line_colors <- setNames(c("black", "black"),    type_levels)
    line_types  <- setNames(c("solid", "dashed"),   type_levels)
    line_sizes  <- setNames(c(1.0,     0.8),        type_levels)
  } else {
    df_h <- do.call(rbind, lapply(seq_len(J), function(j) {
      data.frame(x = X_sorted, y = h_sorted[, j], type = paste0("h_", j))
    }))
    df_all <- rbind(df_env, df_ci, df_h)

    type_levels <- c(env_label, "Confidence Bound",
                     paste0("h_", seq_len(J)))
    df_all$type <- factor(df_all$type, levels = type_levels)

    line_colors <- c("black", "black"); names(line_colors) <- type_levels[1:2]
    line_types  <- c("solid", "dashed"); names(line_types) <- type_levels[1:2]
    line_sizes  <- c(1.2,     0.8);      names(line_sizes) <- type_levels[1:2]

    h_colors <- grDevices::hcl.colors(J, palette = "Set 2")
    for (j in seq_len(J)) {
      nm <- paste0("h_", j)
      line_colors[nm] <- h_colors[j]
      line_types[nm]  <- "solid"
      line_sizes[nm]  <- 0.6
    }
  }

  x <- y <- type <- NULL  # avoid R CMD check NOTE
  p <- ggplot2::ggplot(df_all, ggplot2::aes(
      x = x, y = y,
      color = type, linetype = type, linewidth = type
    )) +
    ggplot2::geom_line() +
    ggplot2::scale_color_manual(values = line_colors) +
    ggplot2::scale_linetype_manual(values = line_types) +
    ggplot2::scale_linewidth_manual(values = line_sizes) +
    ggplot2::labs(x = xlab, y = ylab, color = NULL, linetype = NULL,
                  linewidth = NULL) +
    ggplot2::theme_minimal()

  p
  
}
