% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/favorites.R
\name{get_favorites}
\alias{get_favorites}
\title{GET favorites/list}
\usage{
get_favorites(user, n = 200, ...)
}
\arguments{
\item{user}{Vector of user names, user IDs, or a mixture of both.}

\item{n}{Specifies the number of records to retrieve. Defaults to
200. 3000 is the max number of favorites returned per token.  Due
to suspended or deleted content, this function may return fewer
tweets than the desired (n) number. Must be of length 1 or of
length equal to users}

\item{...}{To see other possible arguments see
\code{\link{get_favorites_call}}.}
}
\value{
A tbl data frame of tweets data with users data attribute.
}
\description{
Returns favorite tweets data for one or more target users.
}
