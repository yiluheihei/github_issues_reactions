#' List reactions of github issues, including the issue comments reactions.
#' 
#' @param repo character, in the format username/repo
github_repo_issues_reactions <- function(repo, ...) {
  issues <- github_repo_issues(repo, ...)
  
  # reactions of issues
  issues_number <- get_issues_item(issues, "number")
  issues_reactions <- github_issues_reactions(repo, issues_number, ...)
  
  # reactions of issues comments
  issues_comments <- purrr::map(issues_number, github_issue_comments, repo = repo, ...)
  issues_comments_ids <- purrr::map(issues_comments, get_issue_comments_item, "id") 
  issues_comments_reactions <- purrr::map(issues_comments_ids, 
    github_issue_comments_reactions, repo = repo, ...)
  
  issues_reactions <- list(
    issue_html = get_issues_item(issues, "html_url"),
    issue_reactions = issues_reactions,
    comment_html = purrr::map(issues_comments, get_issue_comments_item, "html_url"),
    comment_reactions = issues_comments_reactions
  )
  
  issues_reactions
}
