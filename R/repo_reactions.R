issues <- github_repo_issues(repo)
issues_reactions <- purrr::map(issues, get_reactions) %>% dplyr::bind_rows()
issues_meta <- purrr::map_df(issues, `[`, c("id", "html_url", "number")) %>% 
  dplyr::rename(issue_number = number)
issues_reactions <- dplyr::bind_cols(issues_reactions, issues_meta) %>% 
  dplyr::mutate(type = "issue")

comments <- github_repo_comments(repo)
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


get_reactions <- function(x) {
  stopifnot(!"reacitons" %in% names(x))
  reactions <- x$reactions
  reactions[["url"]] <- NULL

  reactions
}
