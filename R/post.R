#' post_tweet
#'
#' @description Posts status update to user's Twitter account
#'
#' @param status Character, tweet status. Must be 140
#'   characters or less.
#' @param media File path to image or video media to be
#'   included in tweet.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @param in_reply_to_status_id Status ID of tweet to which you'd like
#'   to reply. Note: in line with the Twitter API, this parameter is ignored unless the author of the
#'   tweet this parameter references is mentioned within the status text.
#' @examples
#' \dontrun{
#' x <- rnorm(300)
#' y <- x + rnorm(300, 0, .75)
#' col <- c(rep("#002244aa", 50), rep("#440000aa", 50))
#' bg <- c(rep("#6699ffaa", 50), rep("#dd6666aa", 50))
#' tmp <- tempfile(fileext = "png")
#' png(tmp, 6, 6, "in", res = 127.5)
#' par(tcl = -.15, family = "Inconsolata",
#'     font.main = 2, bty = "n", xaxt = "l", yaxt = "l",
#'     bg = "#f0f0f0", mar = c(3, 3, 2, 1.5))
#' plot(x, y, xlab = NULL, ylab = NULL, pch = 21, cex = 1,
#'      bg = bg, col = col,
#'      main = "This image was uploaded by rtweet")
#' grid(8, lwd = .15, lty = 2, col = "#00000088")
#' dev.off()
#' browseURL(tmp)
#' post_tweet(".Call(\"oops\", ...)",
#'            media = tmp)
#'
#' # example of replying within a thread
#' post_tweet(status="first in a thread")
#' my_timeline <- get_timeline(self_user_name, n=1, token=twitter_token)
#' reply_id <- my_timeline[1,]$status_id
#' post_tweet(status="second in the thread", in_reply_to_status_id=reply_id)
#' }
#' @family post
#' @aliases post_status
#' @export
post_tweet <- function(status = "my first rtweet #rstats",
                       media = NULL,
                       token = NULL,
                       in_reply_to_status_id = NULL) {

  ## validate
  stopifnot(is.character(status))
  stopifnot(length(status) == 1)
  query <- "statuses/update"
  if (all(nchar(status) > 140, !grepl("http", status))) {
    stop("cannot exceed 140 characters.", call. = FALSE)
  }
  if (length(status) > 1) {
    stop("can only post one status at a time",
         call. = FALSE)
  }
  token <- check_token(token, query)

  ## media if provided
  if (!is.null(media)) {
    media2upload <- httr::upload_file(media)
    query <- "media/upload"
    rurl <- paste0(
      "https://upload.twitter.com/1.1/media/upload.json"
    )
    r <- httr::POST(rurl, body = list(media = media2upload), token)
    r <- httr::content(r, "parsed")
    params <- list(
      status = status,
      media_ids = r$media_id_string
    )
  } else {
    params <- list(status = status)
  }
  query <- "statuses/update"
  if (!is.null(in_reply_to_status_id)) {
    params[["in_reply_to_status_id"]] <- in_reply_to_status_id
  }

  url <- make_url(query = query, param = params)

  r <- TWIT(get = FALSE, url, token)

  if (r$status_code != 200) {
    httr::content(r, "parsed")
    ##message(paste0(
    ##  "something didn't work. are you using the token associated ",
    ##  "with *your* Twitter account? if so you may need to set read/write ",
    ##  "permissions or reset your token at apps.twitter.com."))
  }
  message("your tweet has been posted!")
  invisible(r)
}


#' post_message
#'
#' @description Posts direct message from user's Twitter account
#'
#' @param text Character, text of message.
#' @param user Screen name or user ID of message target.
#' @param media File path to image or video media to be
#'   included in tweet.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @importFrom httr POST upload_file content
#' @export
post_message <- function(text, user, media = NULL, token = NULL) {
    ## validate
  stopifnot(is.character(text))
  stopifnot(length(text) == 1)
  query <- "direct_messages/new"
  if (length(text) > 1) {
    stop("can only post one message at a time",
         call. = FALSE)
  }
  token <- check_token(token, query)
  ## media if provided
  if (!is.null(media)) {
    media2upload <- httr::upload_file(media)
    rurl <- paste0(
      "https://upload.twitter.com/1.1/media/upload.json"
    )
    r <- httr::POST(rurl, body = list(media = media2upload), token)
    r <- httr::content(r, "parsed")
    params <- list(
      text = text,
      user = user,
      media_ids = r$media_id_string
    )
  } else {
    params <- list(text = text, user = user)
  }
  names(params)[2] <- .id_type(user)
  query <- "direct_messages/new"
  url <- make_url(query = query, param = params)
  r <- TWIT(get = FALSE, url, token)
  if (r$status_code != 200) {
    httr::content(r, "parsed")
  }
  message("your tweet has been posted!")
  invisible(r)
}

#' post_follow
#'
#' @description Follows target twitter user.
#'
#' @param user Screen name or user id of target user.
#' @param destroy Logical indicating whether to post (add) or
#'   remove (delete) target tweet as favorite.
#' @param mute Logical indicating whether to mute the intended
#'   friend (you must already be following this account prior
#'   to muting them)
#' @param notify Logical indicating whether to enable notifications
#'   for target user. Defaults to false.
#' @param retweets Logical indicating whether to enable retweets
#'   for target user. Defaults to true.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @aliases follow_user
#' @examples
#' \dontrun{
#' post_follow("BarackObama")
#' }
#' @family post
#' @export
post_follow <- function(user,
                        destroy = FALSE,
                        mute = FALSE,
                        notify = FALSE,
                        retweets = TRUE,
                        token = NULL) {

  stopifnot(is.atomic(user), is.logical(notify))

  token <- check_token(token)

  if (all(!destroy, !retweets)) {
    query <- "friendships/update"
    params <- list(
      user_type = user,
      notify = notify,
      retweets = retweets)
  } else if (mute) {
    query <- "mutes/users/create"
    params <- list(
      user_type = user)
  } else if (destroy) {
    query <- "friendships/destroy"
    params <- list(
      user_type = user,
      notify = notify)
  } else {
    query <- "friendships/create"
    params <- list(
      user_type = user,
      notify = notify)
  }

  names(params)[1] <- .id_type(user)

  url <- make_url(query = query, param = params)

  r <- TWIT(get = FALSE, url, token)

  if (r$status_code != 200) {
    message(paste0(
      "something didn't work. are you using a token associated ",
      "with *your* Twitter account? if so you may need to set read/write ",
      "permissions or reset your token at apps.twitter.com."))
  }

  r
}

#' post_unfollow
#'
#' Remove, or unfollow, current twitter friend. Wrapper function
#'   for destroy version of follow_user.
#'
#' @param user Screen name or user id of target user.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @aliases unfollow_user
#' @family post
#' @export
post_unfollow_user <- function(user, token = NULL) {
  post_follow(user, destroy = TRUE, token = token)
}

#' post_mute
#'
#' Mute, or hide all content coming from, current twitter friend.
#'   Wrapper function for mute version of follow_user.
#'
#' @param user Screen name or user id of target user.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @aliases mute_user
#' @family post
#' @export
post_mute <- function(user, token = NULL) {
  post_follow(user, mute = TRUE, token = token)
}


#' post_favorite
#'
#' @description Favorites target status id.
#'
#' @param status_id Status id of target tweet.
#' @param destroy Logical indicating whether to post (add) or
#'   remove (delete) target tweet as favorite.
#' @param include_entities Logical indicating whether to
#'   include entities object in return.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @aliases post_favourite favorite_tweet
#' @examples
#' \dontrun{
#' rt <- search_tweets("rstats")
#' r <- lapply(rt$user_id, post_favorite)
#' }
#' @family post
#' @export
post_favorite <- function(status_id,
                          destroy = FALSE,
                          include_entities = FALSE,
                          token = NULL) {

  stopifnot(is.atomic(status_id))

  token <- check_token(token)

  if (destroy) {
    query <- "favorites/destroy"
  } else {
    query <- "favorites/create"
  }

  params <- list(
    id = status_id)

  url <- make_url(query = query, param = params)

  r <- TWIT(get = FALSE, url, token)

  if (r$status_code != 200) {
    message(paste0(
      "something didn't work. are you using a token associated ",
      "with *your* Twitter account? if so you may need to set read/write ",
      "permissions or reset your token at apps.twitter.com."))
  }
  invisible(r)
}


#' post_friendship
#'
#' Updates friendship notifications and retweet abilities.
#'
#' @param user Screen name or user id of target user.
#' @param device Logical indicating whether to enable or disable
#'    device notifications from target user behaviors. Defaults
#'    to false.
#' @param retweets Logical indicating whether to enable or disable
#'    retweets from target user behaviors. Defaults to false.
#' @param token OAuth token. By default \code{token = NULL}
#'   fetches a non-exhausted token from an environment
#'   variable tokens.
#' @aliases friendship_update
#' @family post
#' @export
post_friendship <- function(user,
                            device = FALSE,
                            retweets = FALSE,
                            token = NULL) {

  stopifnot(is.atomic(user), is.logical(device),
            is.logical(retweets))

  token <- check_token(token)

  query <- "friendships/update"

  params <- list(
    user_type = user,
    device = device,
    retweets = retweets)

  names(params)[1] <- .id_type(user)

  url <- make_url(query = query, param = params)

  r <- TWIT(get = FALSE, url, token)

  if (r$status_code != 200) {
    message(paste0(
      "something didn't work. are you using a token associated ",
      "with *your* Twitter account? if so you may need to set read/write ",
      "permissions or reset your token at apps.twitter.com."))
  }
  invisible(r)
}

