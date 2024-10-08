################################################################################

#' Theme ggplot2
#'
#' Theme ggplot2 used by this package.
#'
#' @param size.rel Relative size. Default is `1`.
#'
#' @import ggplot2
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#' (p <- ggplot(mapping = aes(x = 1:10, y = 1:10)) + geom_point())
#' p + theme_bw()
#' p + theme_bigstatsr()
theme_bigstatsr <- function(size.rel = 1) {
  theme_bw() +
    theme(
      plot.title    = element_text(size = rel(2.0 * size.rel), hjust = 0.5),
      plot.subtitle = element_text(size = rel(1.5 * size.rel), hjust = 0.5),
      legend.title  = element_text(size = rel(1.8 * size.rel)),
      legend.text   = element_text(size = rel(1.3 * size.rel)),
      axis.title    = element_text(size = rel(1.5 * size.rel)),
      axis.text     = element_text(size = rel(1.2 * size.rel)),
      strip.text.x  = element_text(size = rel(1.8 * size.rel)),
      strip.text.y  = element_text(size = rel(1.8 * size.rel)),
      legend.key.height = unit(1.3 * size.rel, "line"),
      legend.key.width  = unit(1.3 * size.rel, "line")
    )
}

#' @importFrom cowplot plot_grid
#' @export
cowplot::plot_grid

################################################################################

#' Plot method
#'
#' Plot method for class `big_SVD`.
#'
#' @param x An object of class `big_SVD`.
#' @param type Either
#' - "screeplot": plot of decreasing singular values (the default).
#' - "scores": plot of the scores associated with 2 Principal Components.
#' - "loadings": plot of loadings associated with 1 Principal Component.
#' @param nval Number of singular values to plot. Default plots all computed.
#' @param scores Vector of indices of the two PCs to plot. Default plots the
#' first two PCs. If providing more than two, it produces many plots.
#' @param loadings Indices of PC loadings to plot. Default plots the
#' first vector of loadings.
#' @param cols Deprecated. Use `ncol` instead.
#' @param ncol If multiple vector of loadings are to be plotted, this defines
#' the number of columns of the resulting multiplot.
#' @param coeff Relative size of text. Default is `1`.
#' @param viridis Deprecated argument.
#' @param ... Not used.
#'
#' @return A `ggplot2` object. You can plot it using the `print` method.
#' You can modify it as you wish by adding layers. You might want to read
#' [this chapter](https://r4ds.had.co.nz/data-visualisation.html)
#' to get more familiar with the package **ggplot2**.
#'
#' @export
#' @import ggplot2
#' @importFrom graphics plot
#'
#' @example examples/example-plot-bigSVD.R
#'
#' @seealso [big_SVD], [big_randomSVD] and [asPlotlyText].
#'
plot.big_SVD <- function(x, type = c("screeplot", "scores", "loadings"),
                         nval = length(x$d),
                         scores = c(1, 2),
                         loadings = 1,
                         ncol = NULL,
                         coeff = 1,
                         viridis = TRUE,
                         cols = 2,
                         ...) {

  assert_nodots()

  if (!missing(viridis))
    warning2("Argument 'viridis' is deprecated and will be removed.")
  if (!missing(cols)) {
    warning2("Argument 'cols' is deprecated and will be removed; %s",
             "please use parameter 'ncol' instead.")
    ncol <- cols
  }

  type <- match.arg(type)

  if (type == "screeplot") {

    assert_lengths(nval, 1)

    p <- ggplot(mapping = aes(x = seq_len(nval), y = x$d[seq_len(nval)])) +
      theme_bigstatsr(size.rel = coeff) +
      geom_point() +
      geom_line() +
      scale_y_log10() +
      labs(title = "Scree Plot", x = "PC Index", y = "Singular Value")

    `if`(nval > 12, p, p + scale_x_discrete(limits = factor(seq_len(nval))))

  } else if (type == "scores") {

    if (is.list(scores)) {

      all.p <- lapply(scores, function(scores.part) {
        plot(x, type = "scores", scores = scores.part, coeff = coeff)
      })

      plot_grid(plotlist = all.p, ncol = ncol, scale = 0.95)

    } else {

      if (length(scores) > 2) {

        n_plot <- floor(length(scores) / 2)
        scores.list <- split(utils::head(scores, 2 * n_plot),
                             rep(seq_len(n_plot), each = 2))
        plot(x, type = "scores", scores = scores.list, ncol = ncol, coeff = coeff)

      } else {

        sc <- predict(x)
        nx <- scores[1]
        ny <- scores[2]

        ggplot(mapping = aes(x = sc[, nx], y = sc[, ny])) +
          geom_point() +
          theme_bigstatsr(size.rel = coeff) +
          coord_fixed() +
          labs(title = "Scores of PCA", x = paste0("PC", nx), y = paste0("PC", ny))

      }

    }

  } else if (type == "loadings") {

    if (length(loadings) > 1) {

      all.p <- lapply(loadings, function(i) {
        p <- plot(x, type = "loadings", loading = i, coeff = coeff)
        p$layers[[1]] <- NULL
        p + geom_hex() + scale_fill_viridis_c()
      })

      plot_grid(plotlist = all.p, align = "hv", ncol = ncol, scale = 0.95)

    } else {

      p <- ggplot(mapping = aes(x = rows_along(x$v), y = x$v[, loadings])) +
        geom_point() +
        theme_bigstatsr(size.rel = coeff) +
        labs(title = paste0("Loadings of PC", loadings),
             x = "Column index", y = NULL)

      nval <- nrow(x$v)
      `if`(nval > 12, p, p + scale_x_discrete(limits = factor(seq_len(nval))))

    }

  }
}

################################################################################

#' Plot method
#'
#' Plot method for class `mhtest`.
#'
#' @param x An object of class `mhtest`.
#' @param type Either.
#' - "hist": histogram of p-values (the default).
#' - "Manhattan": plot of the negative logarithm (in base 10) of p-values.
#' - "Q-Q": Q-Q plot.
#' - "Volcaco": plot of the negative logarithm of p-values against the
#'   estimation of coefficients (e.g. betas in linear regression)
#' @param coeff Relative size of text. Default is `1`.
#' @param ... Not used.
#'
#' @inherit plot.big_SVD return
#'
#' @export
#' @import ggplot2
#' @importFrom graphics plot
#'
#' @examples
#' set.seed(1)
#'
#' X <- big_attachExtdata()
#' y <- rnorm(nrow(X))
#' test <- big_univLinReg(X, y)
#'
#' plot(test)
#' plot(test, type = "Volcano")
#' plot(test, type = "Q-Q")
#' plot(test, type = "Manhattan")
#' plot(test, type = "Manhattan") + ggplot2::ggtitle(NULL)
#'
#' @seealso [big_univLinReg], [big_univLogReg],
#' [plot.big_SVD] and [asPlotlyText].
plot.mhtest <- function(x, type = c("hist", "Manhattan", "Q-Q", "Volcano"),
                        coeff = 1,
                        ...) {

  assert_nodots()

  lpval <- predict(x) # log10(p)

  type <- match.arg(type)
  main <- paste(type, "plot")

  p <- if (type == "Manhattan") {
    ggplot(mapping = aes(x = seq_along(lpval), y = -lpval)) +
      geom_point() +
      labs(title = main, x = "Column Index",
           y = expression(-log[10](italic("p-value"))))
  } else if (type == "Volcano") {
    ggplot(mapping = aes(x = x[["estim"]], y = -lpval)) +
      geom_point() +
      labs(title = main, x = "Estimate",
           y = expression(-log[10](italic("p-value"))))
  } else if (type == "Q-Q") {
    unif.ranked <- stats::ppoints(length(lpval))[rank(lpval)]
    ggplot(mapping = aes(x = -log10(unif.ranked), y = -lpval)) +
      geom_point() +
      labs(title = main,
           x = expression(Expected~~-log[10](italic("p-value"))),
           y = expression(Observed~~-log[10](italic("p-value")))) +
      geom_abline(slope = 1, intercept = 0, color = "red")
  } else if (type == "hist") {
    pval <- 10^lpval
    h <- graphics::hist(pval, breaks = "FD", plot = FALSE)
    ggplot() +
      geom_histogram(aes(pval), breaks = h$breaks,
                     color = "#FFFFFF", fill = "#000000", alpha = 0.5) +
      labs(x = "p-value")
  }

  p + theme_bigstatsr(size.rel = coeff)
}

################################################################################

#' Plot method
#'
#' Plot method for class `big_sp_list`.
#'
#' @param x An object of class `big_sp_list`.
#' @param coeff Relative size of text. Default is `1`.
#' @param ... Not used.
#'
#' @inherit plot.big_SVD return
#'
#' @export
#' @import ggplot2 foreach
#' @importFrom graphics plot
#'
plot.big_sp_list <- function(x, coeff = 1, ...) {

  assert_nodots()

  info <- foreach(mods = x, .combine = "rbind") %do% {
    foreach(k = seq_along(mods), .combine = "rbind") %do% {
      mod <- mods[[k]]
      loss <- mod$loss.val
      cbind.data.frame(
        set            = k,
        alpha          = mod$alpha,
        power_adaptive = other_if_null(mod$power_adaptive, 0),
        power_scale    = other_if_null(mod$power_scale,    1),
        loss_index     = seq_along(loss),
        loss           = loss
      )
    }
  }

  ggplot(info) +
    theme_bigstatsr(size.rel = coeff) +
    geom_point(aes(loss_index, loss, color = as.factor(set))) +
    facet_grid(power_adaptive + power_scale ~ alpha, labeller = signif) +
    scale_colour_discrete(guide = FALSE) +
    labs(x = "Index", y = "Loss for each validation set")
}

################################################################################

#' Plotly text
#'
#' Convert a data.frame to plotly text
#'
#' @param df A data.frame
#'
#' @return A character vector of the length of `df`'s number of rows.
#' @export
#'
#' @examples
#' set.seed(1)
#'
#' X <- big_attachExtdata()
#' svd <- big_SVD(X, big_scale(), k = 10)
#'
#' p <- plot(svd, type = "scores")
#'
#' pop <- rep(c("POP1", "POP2", "POP3"), c(143, 167, 207))
#' df <- data.frame(Population = pop, Index = 1:517)
#'
#' plot(p2 <- p + ggplot2::aes(text = asPlotlyText(df)))
#' \dontrun{plotly::ggplotly(p2, tooltip = "text")}
asPlotlyText <- function(df) {
  paste.br <- function(lhs, rhs) paste(lhs, rhs, sep = "<br>")
  foreach(ic = seq_along(df), .combine = paste.br) %do% {
    paste(names(df)[ic], df[[ic]], sep = ": ")
  }
}

################################################################################

#' Get coordinates on plot
#'
#' Get coordinates on a plot by mouse-clicking.
#'
#' @param nb Number of positions.
#' @param digits 2 integer indicating the number of decimal places
#' (respectively for x and y coordinates).
#'
#' @return A list of coordinates. Note that if you don't put the result in a
#' variable, it returns as the command text for generating the list. This can
#' be useful to get coordinates by mouse-clicking once, but then using the code
#' for convenience and reproducibility.
#' @export
#'
#' @examples
#' \dontrun{
#' plot(runif(20, max = 5000))
#' # note the negative number for the rounding of $y
#' coord <- pasteLoc(3, digits = c(2, -1))
#' text(coord, c("a", "b", "c"))
#' }
pasteLoc <- function(nb, digits = c(3, 3)) {
  loc <- graphics::locator(nb)
  loc$x <- round(loc$x, digits[1])
  loc$y <- round(loc$y, digits[2])
  dput(loc, control = NULL)
}

################################################################################
