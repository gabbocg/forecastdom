#include <Rcpp.h>
#include <algorithm>
using namespace Rcpp;

// Column-wise maximum of a matrix (replaces apply(x, 2, max))
// [[Rcpp::export]]
NumericVector colmax_cpp(const NumericMatrix& x) {
  int nr = x.nrow(), nc = x.ncol();
  NumericVector out(nc);
  for (int j = 0; j < nc; j++) {
    double mx = x(0, j);
    for (int i = 1; i < nr; i++) {
      if (x(i, j) > mx) mx = x(i, j);
    }
    out[j] = mx;
  }
  return out;
}

// Column-wise maximum over selected rows only
// [[Rcpp::export]]
NumericVector colmax_selected_cpp(const NumericMatrix& x,
                                  const LogicalVector& selected) {
  int nr = x.nrow(), nc = x.ncol();
  NumericVector out(nc);

  int first = -1;
  for (int i = 0; i < nr; i++) {
    if (selected[i]) { first = i; break; }
  }
  if (first < 0) {
    std::fill(out.begin(), out.end(), R_NegInf);
    return out;
  }

  for (int j = 0; j < nc; j++) {
    double mx = x(first, j);
    for (int i = first + 1; i < nr; i++) {
      if (selected[i] && x(i, j) > mx) mx = x(i, j);
    }
    out[j] = mx;
  }
  return out;
}

// Divide each row of tstat (n x R) by sigma (length n), then take column max
// Avoids creating the full n x R divided matrix in R
// tstat is already P %*% xi_j computed via BLAS
// [[Rcpp::export]]
NumericVector divide_colmax_cpp(const NumericMatrix& tstat,
                                const NumericVector& sigma) {
  int n = tstat.nrow(), R = tstat.ncol();
  NumericVector out(R);
  for (int r = 0; r < R; r++) {
    double mx = tstat(0, r) / sigma[0];
    for (int i = 1; i < n; i++) {
      double val = tstat(i, r) / sigma[i];
      if (val > mx) mx = val;
    }
    out[r] = mx;
  }
  return out;
}

// Same but only over selected rows
// [[Rcpp::export]]
NumericVector divide_colmax_selected_cpp(const NumericMatrix& tstat,
                                          const NumericVector& sigma,
                                          const LogicalVector& selected) {
  int n = tstat.nrow(), R = tstat.ncol();
  NumericVector out(R);

  int first = -1;
  for (int i = 0; i < n; i++) {
    if (selected[i]) { first = i; break; }
  }
  if (first < 0) {
    std::fill(out.begin(), out.end(), R_NegInf);
    return out;
  }

  for (int r = 0; r < R; r++) {
    double mx = tstat(first, r) / sigma[first];
    for (int i = first + 1; i < n; i++) {
      if (!selected[i]) continue;
      double val = tstat(i, r) / sigma[i];
      if (val > mx) mx = val;
    }
    out[r] = mx;
  }
  return out;
}

// P-value search via binary search on sorted critical values
// sorted_max is ascending. We search from top (r=R) down for where
// theta = min(h_hat + kr * sigma_jx_t / sqrt_n) crosses zero.
// Uses binary search: O(log R * n * J) instead of O(R * n * J)
// [[Rcpp::export]]
double pvalue_search_cpp(const NumericMatrix& h_hat,
                         const NumericMatrix& sigma_jx_t,
                         const NumericVector& sorted_max,
                         double sqrt_n) {
  int R = sorted_max.size();
  int n = h_hat.nrow();
  int J = h_hat.ncol();

  // Helper lambda: compute theta for a given kr
  // theta = min over (j, i) of h_hat(i,j) + kr * sigma_jx_t(i,j) / sqrt_n
  auto compute_theta = [&](double kr) -> double {
    double min_val = R_PosInf;
    for (int j = 0; j < J; j++) {
      for (int i = 0; i < n; i++) {
        double val = h_hat(i, j) + kr * sigma_jx_t(i, j) / sqrt_n;
        if (val < min_val) min_val = val;
      }
    }
    return min_val;
  };

  // Check boundaries
  // At r=R (index R-1): largest kr
  if (compute_theta(sorted_max[R - 1]) <= 0.0) {
    // theta <= 0 even at largest kr => search linearly from top
    // (this is the rare case where pvalue is very large)
    for (int r = R - 2; r >= 0; r--) {
      if (compute_theta(sorted_max[r]) > 0.0) {
        return 1.0 - (double)(r + 1) / (double)R;
      }
    }
    return 1.0;
  }

  // At r=1 (index 0): smallest kr
  if (compute_theta(sorted_max[0]) > 0.0) {
    return 0.0;  // theta > 0 everywhere
  }

  // Binary search: find largest index where theta <= 0
  // sorted_max is ascending, so theta is monotonically increasing with index
  int lo = 0, hi = R - 1;
  while (lo < hi - 1) {
    int mid = (lo + hi) / 2;
    if (compute_theta(sorted_max[mid]) > 0.0) {
      hi = mid;
    } else {
      lo = mid;
    }
  }

  // lo is last index where theta <= 0, hi is first where theta > 0
  // The R code: pvalue = 1 - r/R where r is the value where theta first > 0
  // r corresponds to hi+1 in 1-based indexing
  return 1.0 - (double)(hi) / (double)R;
}
