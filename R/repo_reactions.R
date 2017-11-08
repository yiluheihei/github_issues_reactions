#' List reactions of github issues, also including the issue comments reactions.
#' 
#' @param repo character, in the format `username/repo`
#' @param pull_request every pull request is an issue, and we discard the pull 
#' request by default.
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
#' `id`: id of an issue or a comment
#' `html_url`: html url, we can view he details of the issue or comment in our 
#' browser `browseURL(html_url)`
#' `issue_number`:  the number of the issue
#' `type`: "issue" or "comment"
#' and we can view he details of the issue or comment in our browser
#' `browseURL(file.path("https://github.com", repo, "issues", path))` 
github_repo_issue_reactions <- function(repo, pull_request = FALSE, per_page = 100, ...) {
  issues <- github_repo_issues(repo, pull_request, per_page, ...)
  issues_reactions <- purrr::map(issues, get_reactions) %>% dplyr::bind_rows()
  issues_meta <- purrr::map_df(issues, `[`, c("id", "html_url", "number")) %>% 
    dplyr::rename(issue_number = number)
  issues_reactions <- dplyr::bind_cols(issues_reactions, issues_meta) %>% 
    dplyr::mutate(type = "issue")
  
  comments <- github_repo_comments(repo, pull_request, per_page)
  # keep comments in consistent with issues
  issues_url <- purrr::map_chr(issues, "url")
  comments <- purrr::keep(comments, ~ .x$issue_url %in% issues_url)
  comments_reactions <- purrr::map(comments, get_reactions) %>% dplyr::bind_rows()
  comments_meta <- purrr::map_df(comments, `[`, c("id", "html_url"))
  comments_issue_number <- as.integer(purrr::map_chr(comments, get_issue_number))
  comments_meta$issue_number <- comments_issue_number
  comments_reactions <- dplyr::bind_cols(comments_reactions, comments_meta) %>% 
    dplyr::mutate(type = "comment")
  
  reactions <- dplyr::bind_rows(issues_reactions, comments_reactions) %>% 
    dplyr::arrange(issue_number)
}


get_reactions <- function(x) {
  stopifnot(!"reacitons" %in% names(x))
  reactions <- x$reactions
  reactions[["url"]] <- NULL

  reactions
}
