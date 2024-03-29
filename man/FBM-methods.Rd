% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FBM.R
\name{FBM-methods}
\alias{FBM-methods}
\alias{[,FBM,ANY,ANY,ANY-method}
\alias{[<-,FBM,ANY,ANY,ANY-method}
\alias{dim,FBM-method}
\alias{length,FBM-method}
\alias{typeof,FBM-method}
\alias{diag,FBM-method}
\title{Methods for the FBM class}
\usage{
\S4method{[}{FBM,ANY,ANY,ANY}(x, i, j, ..., drop = TRUE)

\S4method{[}{FBM,ANY,ANY,ANY}(x, i, j, ...) <- value

\S4method{dim}{FBM}(x)

\S4method{length}{FBM}(x)

\S4method{typeof}{FBM}(x)

\S4method{diag}{FBM}(x)
}
\arguments{
\item{x}{A \link[=FBM-class]{FBM} object.}

\item{i}{A vector of indices (or nothing). You can use positive and negative
indices, logical indices (that are recycled) and also a matrix of indices
(but only positive ones).}

\item{j}{A vector of indices (or nothing). You can use positive and negative
indices, logical indices (that are recycled).}

\item{...}{Not used. Just to make \link{nargs} work.}

\item{drop}{Whether to delete the dimensions of a matrix which have
one dimension equals to 1.}

\item{value}{The values to replace. Should be of length 1 or of the same
length of the subset to replace.}
}
\description{
Methods for the FBM class

Accessor methods for class \code{FBM}. You can use positive and negative indices,
logical indices (that are recycled) and also a matrix of indices (but only
positive ones).

Dimension and type methods for class \code{FBM}.
}
