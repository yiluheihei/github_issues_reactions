github_repo_comments <- function(repo, pull_request = FALSE, per_page =100) {
  path <- file.path("repos", repo, "issues", "comments")
  resp <- github_GET(path, 
    headers = c(Accept = "application/vnd.github.squirrel-girl-preview"),
    per_page = per_page
  )
  parsed <- github_pagination(resp)
  # discard pull request
  if (!pull_request)
    parsed <- purrr::discard(parsed, is_pull)
  
  parsed
}

is_pull <- function(comment) {
  stringr::str_detect(comment$html_url, "/pull/")
}

get_issue_number <- function(comment) {
  issue_url <- comment$issue_url
  tail(unlist(stringr::str_split(issue_url, "/")), 1)
}


