#' List issues for a repository.
#' @param repo, character, in the format `username/repo`
#' @param ..., parameters, more details in 
#' [https://developer.github.com/v3/issues/#list-issues-for-a-repository](https://developer.github.com/v3/issues/#list-issues-for-a-repository)
#' @details NB:  more details in
#' [https://developer.github.com/v3/#pagination](https://developer.github.com/v3/#pagination)
#' @return a list, an element represents the content of an issue 

github_repo_issues <- function(repo, ...) {
  path <- file.path("repos", repo, "issues")
  resp <- github_GET(path, ...)
  # parsed <- github_parse(resp)
  # 
  # if (!length(parsed))
  #   return(NULL)
  # 
  # while (has_next_link(resp)) {
  #   resp <- github_next_page(resp)
  #   parsed <- append(parsed, github_parse(resp))
  # }
  parsed <- github_pagination(resp)
  
  parsed
}

get_issues_item <- function(issues, item) {
  if (is.null(issues))
    return(NULL)
    
  purrr::map(issues, item)
}


#' List comments of an issue
github_issue_comments <- function(repo, issue_number, ...) {
  path <- file.path("repos", repo, "issues", issue_number, "comments")
  resp <- github_GET(path, ...) 
  # parsed <- github_parse(resp)
  # 
  # if (!length(parsed))
  #   return(NULL)
  # 
  # while (has_next_link(resp)) {
  #   resp <- github_next_page(resp)
  #   parsed <- append(parsed, github_parse(resp))
  # }
  parsed <- github_pagination(resp)

  parsed
}

get_issue_comments_item <- function(issue_comments, item) {
  if (is.null(issue_comments))
    return(NULL)
    
  purrr::map(issue_comments, item)
}