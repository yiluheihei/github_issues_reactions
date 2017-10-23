#' List reactions of an issue
github_issue_reactions <- function(repo, id, ...) {
  github_reactions(repo, type = "issue", id, ...)
}

#' List reactions of a list of issues
github_issues_reactions <- function(repo, ids, ...) {
  if (is.null(ids))
    return(NULL)
  
  purrr::map(ids, github_issue_reactions, repo = repo, ...)
}

#' List reactions of all comments of an issue
github_issue_comments_reactions <- function(repo, ids, ...) {
  if (!length(ids))
    return(NULL)
  
  purrr::map(ids, github_reactions, repo = repo, type = "comment")
}

#' List github reactions of an issue, or an issue comment
#' 
#' @param repo
#' @param type "issue" or "comment", which indicates the types of reactions
#' @param id issue number while type is "issue", or comment id while type is "comment"
#' 
#' @return a list (of length 7), 
#' * total_count: total count of reactions
#' * `+1`: count of emoji `:+1:`
#' * `-1`: count of emoji `:-1:`
#' * laugh: count of emoji `:smile:`
#' * confused: count of emoji `:confused:`
#' * heart: count of emoji `:heart:`
#' * hooray: count of emoji `:tada:`
github_reactions <- function(repo, type = c("issue", "comment"), id, ...) {
  type <- match.arg(type, c("issue", "comment"))
  if (type == "issue") 
    path <- file.path("repos", repo, "issues", id)
  else
    path <- file.path("repos", repo, "issues", "comments", id)
  
  resp <- github_GET(path, 
    httr::add_headers(Accept = "application/vnd.github.squirrel-girl-preview+json"),
    ...
  )
  
  if (!length(github_parse(resp)))
    return(NULL)
  
  reactions <- get_reactions(resp)
  if (reactions$total_count == 0)
    return(NULL)
  
  reactions
  
}

get_reactions <- function(resp) {
  reactions <- github_parse(resp) %>% 
    `[[`("reactions")
  reactions[["url"]] <- NULL
  
  reactions
}
