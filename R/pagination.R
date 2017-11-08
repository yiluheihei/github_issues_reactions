github_pagination <- function(resp) {
  parsed <- github_parse(resp)
  
  if (!length(parsed))
    return(NULL)
  
  while (has_next_link(resp)) {
    resp <- github_next_page(resp)
    parsed <- append(parsed, github_parse(resp))
  }
  
  parsed
}

#' Response of next page
github_next_page <- function(resp, access_token = github_pat()) {
  # resp <- github_resp$resp
  if (!has_next_link(resp))
    return(NULL)
  next_link <- parse_links(resp)["next"]
  resp <- httr::GET(next_link, 
    access_token = access_token, 
    httr::add_headers(Accept = "application/vnd.github.squirrel-girl-preview")
  )
  github_errors(resp)
  
  return(resp)
}

#' Parse links in reponse headers
parse_links <- function(resp) {
  links_header <- resp$headers$link %>% 
    stringr::str_split(', ', simplify = TRUE) %>%
    stringr::str_split("; ")
  
  links <- purrr::map_chr(links_header, 1) %>% 
    purrr::map_chr(stringr::str_sub, start = 2L, end = -2L)
  rel <- purrr::map_chr(links_header, 2) %>% 
    purrr::map_chr(stringr::str_sub, start = 6L, end = -2L)
  names(links) <- rel
  
  links
}

has_link <- function(resp) "link" %in% names(resp$headers)

has_next_link <- function(resp) {
  if (!has_link(resp))
    return(FALSE)
  links <- parse_links(resp)
  ifelse("next" %in% names(links), TRUE, FALSE)
}

#' Total page number
parse_pagenum <- function(last_link) str_match(last_link, "page=(\\d+).*$")[2]
