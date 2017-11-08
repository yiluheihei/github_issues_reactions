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

repo <- "rstudio/rmarkdown"
reactions <- github_issue_reactions(repo)

# Sys.setenv(GITHUB_PAT = "a65388f9db8cf809b776666b23c32fbee1c9b564")




# the most upvoted reactions is comment 320504839 of issue 1020
most_upvoted <- dplyr::filter(reactions, `+1` == max(`+1`))
most_upvoted
# we can view the details in the browser
browseURL(most_upvoted$html_url)
# or extract the detials with github api
# # list comments of a  repository
# 
# resp <- github_GET(path = "repos/rstudio/rmarkdown/issues/comments",
#   headers = c(Accept = "application/vnd.github.squirrel-girl-preview"),
#   per_page = 100
# )

