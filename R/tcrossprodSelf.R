################################################################################

#' Tcrossprod
#'
#' Compute \eqn{X.row X.row^T} for a Filebacked Big Matrix `X`
#' after applying a particular scaling to it.
#'
#' @inheritParams bigstatsr-package
#'
#' @inheritSection bigstatsr-package Matrix parallelization
#'
#' @return A temporary [FBM][FBM-class], with the following two attributes:
#' - a numeric vector `center` of column scaling,
#' - a numeric vector `scale` of column scaling.
#' @export
#' @seealso [tcrossprod]
#'
#' @example examples/example-tcrossprodSelf.R
#'
big_tcrossprodSelf <- function(
  X,
  fun.scaling = big_scale(center = FALSE, scale = FALSE),
  ind.row = rows_along(X),
  ind.col = cols_along(X),
  block.size = block_size(nrow(X))
) {

  check_args()

  n <- length(ind.row)
  K <- FBM(n, n, init = 0)
  m <- length(ind.col)

  means <- numeric(m)
  sds   <- numeric(m)

  intervals <- CutBySize(m, block.size)

  X_part_temp <- matrix(0, n, max(intervals[, "size"]))

  for (j in rows_along(intervals)) {
    ind <- seq2(intervals[j, ])
    ind.col.ind <- ind.col[ind]
    ms <- fun.scaling(X, ind.row = ind.row, ind.col = ind.col.ind)
    if (any_near0(ms$scale)) stop2(MSG_ZERO_SCALE)

    means[ind] <- ms$center
    sds[ind]   <- ms$scale
    increment_scaled_tcrossprod(K, X_part_temp, X,
                                ind.row, ind.col.ind,
                                ms$center, ms$scale)
  }

  structure(K, center = means, scale = sds)
}

################################################################################

#' @export
#' @param x A 'double' FBM.
#' @param y Missing.
#' @rdname big_tcrossprodSelf
setMethod("tcrossprod", signature(x = "FBM", y = "missing"),
          function(x, y) tcrossprod_FBM(x))

################################################################################
