/******************************************************************************/

#include <Rcpp.h>

using namespace Rcpp;
using std::size_t;

/******************************************************************************/

// [[Rcpp::export]]
double auc_cpp(const NumericVector& x_pos, const NumericVector& x_neg) {

  size_t n_pos = x_pos.size();
  size_t n_neg = x_neg.size();
  if (n_pos == 0 || n_neg == 0) return NA_REAL;

  double cg = 0, ce = 0;
  size_t i, j;

  for (j = 0; j < n_pos; j++) {
    for (i = 0; i < n_neg; i++) {
      if (x_pos[j] > x_neg[i]) {
        cg++;
      } else if (x_pos[j] == x_neg[i]) {
        ce++;
      }
    }
  }

  double res = cg + ce / 2;
  res /= n_neg;
  res /= n_pos;

  return res;
}

/******************************************************************************/
