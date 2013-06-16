library(utils)
library(rjson)
library(RCurl)

query <- function(q) {
  ## Accepts the API query for a URL request and returns an R list
  ## from a JSON object
  base.url <- "http://localhost:8080/api/counts/"
  req <- paste(base.url, URLencode(q), sep = "")
  print(paste("Request:", req))
  return(fromJSON(getURL(req), unexpected.escape = "skip"))
}

adminPath <- function(...) {
  # Given an arbitrary number of levels, will return the appropriate
  # structure for the API call.

  ## Example usage:
  ##   > adminPath("idn", 2, 3)
  ##   "idn/2/3"
  filtered <- as.list(Filter(function(x) {x != ""}, c(...)))
  return(do.call("paste", c(filtered, sep="/")))
}

dateRange <- function(begin = "", end = "") {
  ## Accepts a date range of the form "%Y-%m-%d" and returns an
  ## appropriately formatted date object.  Note that if a single date
  ## is supplied, then it is assumed that it is the beginning of the
  ## date range, and that the end is the most recent date.

  ## Example usage:
  ##   > dateRange(begin = "2005-12-01", end = "2008-04-14")
  ##   "?date=2005-12-01,2008-04-14"
  query.pre <- "?range="
  if (begin == "" && end == "") {
    return("")
  } else if (begin != "" && end == "") {
    return(paste(query.pre, begin, sep = ""))
  } else if (begin != "" && end != "") {
    return(paste(query.pre, begin, ",", end, sep = ""))
  } else {
    stop("You must supply a valid date range")
  }
}

aggregateQuery <- function(level = "") {
  ## Accepts a level for aggregation and returns the appropriately
  ## formatted query parameter
  if (level != "") {
    return(paste("?aggregate=", level, sep = ""))
  } else {
    return("")
  }
}

dataQuery <- function(iso = "", id1 = "", id2 = "", id3 = "",
                       aggregate.level = "", begin = "", end = "") {
  ## Accepts a specification of the desired data and returns a data
  ## frame of the panel data set

  ## Build the structured query and return the results
  admin <- adminPath(iso, id1, id2, id3)
  agg   <- aggregateQuery(aggregate.level)
  date  <- dateRange(begin, end)
  q <- paste(admin, agg, date, sep = "")
  res <- query(q)

  ## Return a panel data frame
  table <- do.call(rbind.data.frame, res$rows)

  ## convert date string to R date object
  table$date <- as.Date(table$date)
  return(table)
}
