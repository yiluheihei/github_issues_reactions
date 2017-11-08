#' github api GET method
#' 
#' @param path character, url path
#' @param headers which can be used to provide a custom media type, for accessing a
#'   preview feature of the API, e.g. reactions.
#' @param access_token character, your personal access token which was used to 
#' increasing the unauthenticated rate limit for OAuth
#' @param ... github api parameters
github_GET <- function(path, headers = NULL, ..., access_token = github_pat()) {
  host <- "https://api.github.com"
  params <- list(access_token = access_token, ...)
  # resp <- httr::GET(host, path = path, ..., access_token = access_token)
  resp <- httr::GET(host, path = path,  httr::add_headers(headers), query = params)
  github_errors(resp)
  
  return(resp)
}

# authorize and rate limit ------------------------------------------------

#' Github personal access token (PAT), OAuth2 Token, which can be used to 
#' authenticate to the API.
#' 
#' As a default, GitHub only allows 60 API calls per hour for anonymous users. 
#' For authenticated users, GitHub only allows 5000 API calls per hour.
#' So, we can [create the pat](https://github.com/settings/tokens/new) for 
#' increasing the unauthenticated rate limit.
github_pat <- function() {
  pat <- Sys.getenv('GITHUB_PAT')
  if (identical(pat, "")) {
    warning(paste("GitHub only allows 60 API calls per hour, please set env", 
      "GITHUB_PAT to your PAT to increase rate limit to 5000 per hour.", 
      sep = " "),
      call. = FALSE
    )
    return(NULL)
  }
  
  pat
}

has_github_pat <- function() !identical(Sys.getenv("GITHUB_PAT"), "")

#' Show your rate limit of github api of the current session.
#' 
#' @return show message in format "remaining requests / maximum number of requests 
#' (The time at which the current rate limit window resets)"

rate_limit <- function() {
  resp <- github_GET(path = "rate_limit")
  github_errors(resp)
  parsed <- github_parse(resp)
  core <- parsed$resources$core
  
  reset <- as.POSIXct(core$reset, origin = "1970-01-01")
  cat(core$remaining, " / ", core$limit,
    " (Resets at ", strftime(reset, "%H:%M:%S"), ")\n", sep = "")
}

# errors ------------------------------------------------------------------

#' Turn API errors into R errors. Source code from vignettes of httr package
github_errors <- function(resp) {
  parsed <- github_parse(resp)
  
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "GitHub API request failed [%s]\n%s\n<%s>", 
        httr::status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }
}

github_parse <- function(resp) {
  content <- httr::content(resp, as = "text")
  if (identical(content, "")) 
    stop("There is no response in github api", call. = FALSE)
  
  return(jsonlite::fromJSON(content, simplifyVector = FALSE))
} 