# Shared internal helpers for the multi-horizon SPA tests
# (Quaedvlieg, 2021, "Multi-Horizon Forecast Comparison").

# Moving-block-bootstrap indices (Kunsch, 1989).
# Translated from Get_MBB_ID.m. Block length L, total length T_.
# Each new block starts at a uniform random position in 1:T_; within a block the
# index advances by +1 and wraps to 1 once it exceeds T_.
.mbb_indices <- function(T_, L) {

  idx <- integer(T_)
  idx[1] <- sample.int(T_, 1L)

  for (t in seq.int(2L, T_)) {

    if (t %% L == 0L) {

      idx[t] <- sample.int(T_, 1L)

    } else {

      idx[t] <- idx[t - 1L] + 1L

    }

    if (idx[t] > T_) idx[t] <- 1L

  }

  idx

}
