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

Sys.setenv(GITHUB_PAT = "a65388f9db8cf809b776666b23c32fbee1c9b564")


#system.time(repo_issues_reactions <- github_repo_issues_reactions("rstudio/blogdown"))


# NB: progress bar, pagination

# Requests that return multiple items will be paginated to 30 items by default.
# https://developer.github.com/v3/#pagination
repo <- "rstudio/rmarkdown"

# reactions <- github_repo_issues_reactions(repo, state = "all")
# 
# # 46 issues, comment_count is the count of comments of issue
# issues_count <- reactions %>% dplyr::group_by(issue_number) %>% 
#   dplyr::summarise(n=n(), comment_count = n - 1L )

# the most upvoted reactions comment 320504839 of issue 1020
most_upvoted <- dplyr::filter(reactions, `+1` == max(`+1`))
# we can view the details in the browser
browseURL(file.path("https://github.com", repo, "issues", most_upvoted$path))
# or extract the detials with github api
github_GET(
  file.path("repos", 
    repo,
    "issues/comments",
    most_upvoted$comments_id
  )
)


# # list comments of a  repository
# 
# resp <- github_GET(path = "repos/rstudio/rmarkdown/issues/comments",
#   headers = c(Accept = "application/vnd.github.squirrel-girl-preview"),
#   per_page = 100
# )

