% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/friends.R
\name{get_friends}
\alias{get_friends}
\title{GET friends/ids}
\usage{
get_friends(users, retryonratelimit = FALSE, ...)
}
\arguments{
\item{users}{Screen name or user ID of target user from which the user IDs
of friends (accounts followed BY target user) will be retrieved.}

\item{retryonratelimit}{If you'd like to retrieve 5,000 or fewer friends for
more than 15 target users, then set \code{retryonratelimit = TRUE} and
this function will use \code{\link{Sys.sleep}} until rate limits reset and
the desired number of friend networks is retrieved. This defaults
to FALSE. See details for more info regarding possible issues with timing
misfires.}

\item{...}{For other possible args see \code{\link{get_friends.default}}.}
}
\value{
A tibble data frame with two columns, "user" for name or ID of target
  user and "user_id" for follower IDs.
}
\description{
Returns user IDs of accounts followed by target user.
}
\details{
When \code{retryonratelimit = TRUE} this function internally
  makes a rate limit API call to get information on (a) the number of requests
  remaining and (b) the amount of time until the rate limit resets. So, in
  theory, the sleep call should only be called once between waves of data
  collection. However, as a fail safe, if a system's time is calibrated such
  that it expires before the rate limit reset, or if, in another session, the
  user dips into the rate limit, then this function will wait (use Sys.sleep
  for a second time) until the next rate limit reset. Users should monitor
  and test this before making especially large calls as any systematic issues
  could create sizable inefficiencies.
}
