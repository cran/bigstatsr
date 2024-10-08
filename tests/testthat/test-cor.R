################################################################################

context("COR")

set.seed(SEED)

################################################################################

# Simulating some data
N <- 101
M <- 43
x <- matrix(rnorm(N * M, 100, 5), N)

################################################################################

test_that("equality with cor", {
  for (t in TEST.TYPES) {
    X <- `if`(t == "raw", asFBMcode(x), big_copy(x, type = t))

    tmp <- tempfile()
    K <- big_cor(X, block.size = 10, backingfile = tmp)
    expect_equal(K[], cor(X[]))
    expect_identical(K$backingfile, normalizePath(paste0(tmp, ".bk")))
  }
})

################################################################################

test_that("equality with cor with half of the data", {
  ind <- sample(M, M / 2)

  for (t in TEST.TYPES) {
    X <- `if`(t == "raw", asFBMcode(x), big_copy(x, type = t))

    K <- big_cor(X, ind.col = ind, block.size = 10)
    expect_equal(K[], cor(X[, ind]))
  }
})

################################################################################

test_that("equality with cor with half of the data", {
  ind <- sample(N, N / 2)

  for (t in TEST.TYPES) {
    X <- `if`(t == "raw", asFBMcode(x), big_copy(x, type = t))

    K <- big_cor(X, ind.row = ind, block.size = 10)
    expect_equal(K[], cor(X[ind, ]))
  }
})

################################################################################
