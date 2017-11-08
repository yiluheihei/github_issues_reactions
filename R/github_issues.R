#' List issues for a repository.
#' @param repo character, in the format `username/repo`
#' @param pull_request every pull request is an issue, and we discard the pull 
#' request by default.
#' @param per_page set the page size to the maximum 100 for auto pagination
#' @param ..., Name-value pairs giving repository issues parameters, 
#' e.g. `state`, more details in 
#' [https://developer.github.com/v3/issues/#list-issues-for-a-repository](https://developer.github.com/v3/issues/#list-issues-for-a-repository)
#' @return an issue list, an element represents the content of an issue 

github_repo_issues <- function(repo, pull_request = FALSE, per_page = 100, ...) {
  path <- file.path("repos", repo, "issues")
  resp <- github_GET(path, per_page = per_page, ...)
  parsed <- github_pagination(resp)
  
  # discard pull request
  if (!pull_request)
    parsed <- purrr::discard(parsed, ~ is.element("pull_request", names(.x)))

  parsed
}

get_issues_item <- function(issues, item) {
  if (is.null(issues))
    return(NULL)
    
  purrr::map(issues, item)
}


#' List comments of an issue
github_issue_comments <- function(repo, issue_number, per_page = 100) {
  path <- file.path("repos", repo, "issues", issue_number, "comments")
  resp <- github_GET(path, per_page = per_page) 
  parsed <- github_pagination(resp)

  parsed
}

get_issue_comments_item <- function(issue_comments, item) {
  if (is.null(issue_comments))
    return(NULL)
    
  purrr::map(issue_comments, item)
}