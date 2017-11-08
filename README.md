Code for list reactions for issues of a reposity. Just for a [Yihui's blog post](https://yihui.name/en/2017/10/emoji-stats-of-github-issues/).

# Quick start

## Loading dependencies


```r
dependencies <- c("dplyr", "purrr", "httr", "stringr", "jsonlite")

for (pkg in dependencies) {
  if (!require(pkg, character.only = TRUE)) 
    install.packages(pkg, character.only = TRUE)
}

for (file in list.files("R")) {
  cat(file, "\n")
  source(file.path("R", file))
}
```

```
## github_api.R 
## pagination.R 
## repo_comments.R 
## repo_issues.R 
## repo_reactions.R
```

## Token

As a default, GitHub only allows 60 API calls per hour for anonymous users, and the GITHUB_PAT environment variable is used.  I highly recommend to [Create your own pat](https://github.com/settings/tokens/new) and set env `GITHUB_PAT`， for increasing the unauthenticated rate limit for OAuth.


```r
Sys.setenv(GITHUB_PAT = "your_pat")
```

## List reactions

List reactions of an issue and its comment of a given repository:


```r
# taken the rstudio/rmakrdown for example
reactions <- github_repo_issue_reactions("rstudio/rmarkdown")
```

There are 46 opened issues in "rstudio/ramrkdown", var `comment_count` indicates the count of comments of an issue


```r
grouped_reactions <- dplyr::group_by(reactions, issue_number) %>% 
  dplyr::summarise(comment_count = n() - 1L)
grouped_reactions
```

```
## # A tibble: 46 x 2
##    issue_number comment_count
##           <int>         <int>
##  1          139             1
##  2          316             8
##  3          450             2
##  4          455             6
##  5          457             3
##  6          499             2
##  7          502             0
##  8          656             3
##  9          664             1
## 10          701            13
## # ... with 36 more rows
```

As mentioned in the [blog post](https://yihui.name/en/2017/10/emoji-stats-of-github-issues/), the most upvoted reactions is comment 320504839 of issue 1020


```r
most_upvoted <- dplyr::filter(reactions, `+1` == max(`+1`))
most_upvoted
```

```
## # A tibble: 1 x 11
##   total_count  `+1`  `-1` laugh hoor… conf… heart     id html… issu… type 
##         <int> <int> <int> <int> <int> <int> <int>  <int> <chr> <int> <chr>
## 1          26    26     0     0     0     0     0 3.21e⁸ http…  1020 comm…
```

```r
# we can view the details in the browser
browseURL(most_upvoted$html_url)
```

# Pagination

Requests that return multiple items will be paginated to 30 items by default. 

**Note:** While we set the page size to the maximum 100 for auto pagination, and seek to not overstep your rate limit (5000 request per hour, because the 
GITHUB_PAT is setted as token). You probably want to use a custom pattern for traversing large lists.

# gh: GitHub API client in R

Unfortunately，the [gh](https://github.com/r-lib/gh) package, a minimalistic GitHub API client in R, came into my eyes just after finish these codes. 

Maybe I'll rewrite my codes rely on gh for the lowlevel stuff later.

# References

- [https://rpubs.com/marbel/19179](https://rpubs.com/marbel/19179)
- The [vignette](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html) of httr
