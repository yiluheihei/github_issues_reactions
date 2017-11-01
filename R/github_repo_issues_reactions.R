#' List reactions of github issues, also including the issue comments reactions.
#' 
#' @param repo character, in the format `username/repo`
#' @param per_page set the page size to the maximum 100 for auto pagination
#' @param ... name-value pairs giving repository issues parameters, 
#' e.g. `state`, more details in 
#' [https://developer.github.com/v3/issues/#list-issues-for-a-repository](https://developer.github.com/v3/issues/#list-issues-for-a-repository)
#' @return a tibble with 11 variables. Each row represents an issue reactions 
#' (while `type` is "issue"), or a comment reactions of an issue (while `type` is
#' "comment").
#' `total_count`: total reactions
#' `+1`: emoji `:+1:`
#' `-1`: emoji `:-1:`
#' `laugh`: emoji `:smile:`
#' `hooray`: emoji `:tada:`
#' `confused`: emoji `:confused:`
#' `heart`: emoji `:heart`
#' `type`: "issue" or "comment"
#' `issue_number`:  the number of the issue
#' `comments_id`: the id of comment, `NA` if the type is "comment" 
#' `path`: url path, that can be used to construct the url,
#' and we can view he details of the issue or comment in our browser
#' `browseURL(file.path("https://github.com", repo, "issues", path))` 

github_repo_issues_reactions <- function(repo, per_page = 100, ...) {
  issues <- github_repo_issues(repo, per_page = per_page, ...)
  issues_number <- get_issues_item(issues, "number")
  reactions <- purrr::map(issues_number, github_repo_issue_reactions, repo = repo)
  
  dplyr::bind_rows(reactions)
}


#' list reactions of an issue, also including the issue comments reactions.
github_repo_issue_reactions <- function(repo, issue_number) {
  # issue reactions
  issue_reactions <- github_issue_reactions(repo, issue_number)
  
  # comments reactions
  comments <-  github_issue_comments(repo, issue_number)
  comments_id <- get_issue_comments_item(comments, "id")
  comments_reactions <- github_issue_comments_reactions(repo, comments_id)
  
  reactions <- dplyr::bind_rows(issue_reactions, comments_reactions)
  reactions$issue_number <- issue_number
  reactions$comments_id <- c(NA_integer_, unlist(comments_id))
  reactions
  
  if (is.null(comments))
    reactions$path <- as.character(issue_number)
  else
    reactions$path <- c(issue_number, paste0(issue_number, "#issuecomment-", comments_id))
  
  reactions
}
