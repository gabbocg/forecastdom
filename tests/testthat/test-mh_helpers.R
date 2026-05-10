test_that(".mbb_indices returns T integers in 1:T with contiguous L-blocks", {
  set.seed(1)
  T_ <- 50; L <- 5
  idx <- forecastdom:::.mbb_indices(T_, L)
  expect_length(idx, T_)
  expect_true(all(idx >= 1L & idx <= T_))
  # Within a block (positions where t %% L != 0), idx should advance by 1 mod T
  diffs <- diff(idx)
  # diffs[i] = idx[i+1] - idx[i], so a fresh random draw at iteration t = i+1
  # makes diffs[i] unconstrained. The Matlab makes those draws when t %% L == 0,
  # i.e. when (i + 1) %% L == 0.
  in_block <- ((seq_len(T_ - 1) + 1L) %% L) != 0L
  # inside-block diffs are either +1 or -(T-1) (the wrap)
  expect_true(all(diffs[in_block] %in% c(1L, -(T_ - 1L))))
})
