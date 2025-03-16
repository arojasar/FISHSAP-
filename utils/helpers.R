# utils/helpers.R

check_internet <- function() {
  tryCatch({
    url <- "http://www.google.com"
    response <- httr::GET(url, timeout(2))
    return(httr::status_code(response) == 200)
  }, error = function(e) {
    return(FALSE)
  })
}