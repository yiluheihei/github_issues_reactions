# loading packages and functions ------------------------------------------
dependencies <- c("dplyr", "purrr", "httr", "stringr", "jsonlite")

for (pkg in dependencies) {
  if (!require(pkg, character.only = TRUE)) 
    install.packages(pkg, character.only = TRUE)
}

for (file in list.files("R")) {
  cat(file, "\n")
  source(file.path("R", file))
}

# total, issue, commnet1, comment2, comment3, url, html_url
repo <- "rstudio/rmarkdown"
Sys.setenv(GITHUB_PAT = "d6aa776aa44708d1d94c1aa85e987a2be0878d30")

# issues
issues <- github_repo_issues(repo)
issues_number <- get_issues_item(issues, "number")

# comments
issues_comments <- purrr::map(issues_number,
  github_issue_comments, repo = repo)
issues_comments_ids <- purrr::map(issues_comments, get_issue_comments_item, "id") 

# reactions
issues_comments_reactions <- purrr::map(issues_comments_ids, 
  github_issue_comments_reactions, repo = repo)


issues_reactions <- github_repo_issues_reactions(repo)
comments_html <- map(issues_comments, get_issue_comments_item, "html_url")

#默认情况设置参数：per_page = 100
# ... 可以是哪些参数


# NB: progress bar, pagination
