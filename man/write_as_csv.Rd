% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/save.csv.R
\name{write_as_csv}
\alias{write_as_csv}
\title{write_as_csv}
\usage{
write_as_csv(x, file_name)
}
\arguments{
\item{x}{Data frame with tweets and users data.}

\item{file_name}{Desired name(stem) to save files as (one save for tweets,
one save for users).}
}
\value{
Saved csv files in current working directory.
}
\description{
Saves as flattened CSV file Twitter data.
}
