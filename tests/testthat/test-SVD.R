################################################################################

context("SVD")

set.seed(SEED)

options(bigstatsr.downcast.warning = FALSE)

################################################################################

TOL <- 1e-3

# function for sampling scaling
sampleScale <- function() {
  tmp <- sample(list(c(TRUE, FALSE),
                     c(TRUE, TRUE),
                     c(FALSE, FALSE)))[[1]]
  list(center = tmp[1], scale = tmp[2])
}

# Simulating some data
N <- 73
M <- 43
x <- matrix(rnorm(N * M, mean = 100, sd = 5), N)

###############################################################################

svd1 <- big_SVD(as_FBM(x), big_scale(), ind.row = 1:40)
svd2 <- big_randomSVD(as_FBM(x), big_scale(), ind.row = 1:40, tol = 1e-5)
expect_equal(diffPCs(svd1$u, svd2$u), 0, tolerance = TOL)
expect_equal(diffPCs(svd1$v, svd2$v), 0, tolerance = TOL)

svd3 <- big_SVD(as_FBM(x), big_scale(), ind.row = 1:40 + 7, ind.col = 1:30 + 3)
svd4 <- big_randomSVD(as_FBM(x), big_scale(), ind.row = 1:40 + 7,
                      ind.col = 1:30 + 3, tol = 1e-8)
expect_equal(diffPCs(svd3$u, svd4$u), 0, tolerance = TOL)
expect_equal(diffPCs(svd3$v, svd4$v), 0, tolerance = TOL)

###############################################################################

test_that("equality with prcomp", {
  for (t in TEST.TYPES) {
    X <- `if`(t == "raw", asFBMcode(x), big_copy(x, type = t))

    k <- sample(c(1, 2, 10, 20), 1)

    test <- big_SVD(X, k = k)
    pca <- prcomp(X[], center = FALSE, scale. = FALSE)
    expect_equal(diffPCs(predict(test), pca$x), 0, tolerance = TOL)
    expect_equal(diffPCs(test$v, pca$rotation), 0, tolerance = TOL)

    sc <- sampleScale()
    test <- big_SVD(X,
                    fun.scaling = big_scale(center = sc$center,
                                            scale = sc$scale),
                    k = k)
    pca <- prcomp(X[], center = sc$center, scale. = sc$scale)
    expect_equal(diffPCs(predict(test), pca$x), 0, tolerance = TOL)
    expect_equal(diffPCs(test$v, pca$rotation), 0, tolerance = TOL)
    if (sc$center) expect_equal(test$center, pca$center)
    if (sc$scale)  expect_equal(test$scale,  pca$scale)

    p <- plot(test, type = sample(c("screeplot", "scores", "loadings"), 1))
    expect_s3_class(p, "ggplot")
    # expect_equal(p + theme_bigstatsr(1.2), MY_THEME(p, 1.2))

    expect_error(predict(test, abc = 2), "Argument 'abc' not used.")
    expect_error(plot(test, abc = 2), "Argument 'abc' not used.")
  }
})

###############################################################################

test_that("equality with prcomp with half of the data", {
  ind <- sample(N, N / 2)
  ind2 <- setdiff(1:N, ind)

  for (t in TEST.TYPES) {
    X <- `if`(t == "raw", asFBMcode(x), big_copy(x, type = t))

    k <- sample(c(1, 2, 10, 20), 1)
    sc <- sampleScale()

    test <- big_SVD(X,
                    ind.row = ind,
                    fun.scaling = big_scale(center = sc$center,
                                            scale = sc$scale),
                    k = k)
    pca <- prcomp(X[ind, ], center = sc$center, scale. = sc$scale)

    expect_equal(diffPCs(predict(test), pca$x), 0, tolerance = TOL)
    expect_equal(diffPCs(test$v, pca$rotation), 0, tolerance = TOL)

    if (sc$center) expect_equal(test$center, pca$center)
    if (sc$scale)  expect_equal(test$scale,  pca$scale)

    expect_equal(diffPCs(predict(test, X, ind.row = ind2),
                         predict(pca, X[ind2, ])), 0, tolerance = TOL)

    p <- plot(test, type = sample(c("screeplot", "scores", "loadings"), 1))
    expect_s3_class(p, "ggplot")
  }
})

################################################################################

test_that("equality with prcomp with half of half of the data", {
  ind <- sample(N, N / 2)
  ind2 <- setdiff(1:N, ind)
  ind.col <- sample(M, M / 2)

  for (t in TEST.TYPES) {
    X <- `if`(t == "raw", asFBMcode(x), big_copy(x, type = t))

    k <- sample(c(1, 2, 10, 20), 1)
    sc <- sampleScale()

    test <- big_SVD(X,
                    ind.row = ind, ind.col = ind.col,
                    fun.scaling = big_scale(center = sc$center,
                                            scale = sc$scale),
                    k = k)
    pca <- prcomp(X[ind, ind.col], center = sc$center, scale. = sc$scale)

    expect_equal(diffPCs(predict(test), pca$x), 0, tolerance = TOL)
    expect_equal(diffPCs(test$v, pca$rotation), 0, tolerance = TOL)

    if (sc$center) expect_equal(test$center, pca$center)
    if (sc$scale)  expect_equal(test$scale,  pca$scale)

    expect_equal(diffPCs(predict(test, X, ind.row = ind2, ind.col = ind.col),
                         predict(pca, X[ind2, ind.col])), 0, tolerance = TOL)

    p <- plot(test, type = sample(c("screeplot", "scores", "loadings"), 1))
    expect_s3_class(p, "ggplot")
  }
})

################################################################################

expect_s3_class(p <- plot(svd1, type = "scores"), "ggplot")
expect_length(p$layers, 1)
expect_s3_class(p <- plot(svd1, type = "scores", scores = 3:4), "ggplot")
expect_length(p$layers, 1)
expect_s3_class(p <- plot(svd1, type = "scores", scores = 1:8), "ggplot")
expect_length(p$layers, 4)
expect_s3_class(p <- plot(svd1, type = "scores", scores = 1:9), "ggplot")
expect_length(p$layers, 4)

###############################################################################
