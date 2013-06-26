library(utils)
library(rjson)
library(RCurl)

query <- function(q) {
  ## Accepts the API query for a URL request and returns an R list
  ## from a JSON object
  base.url <- "http://wip.forma-api.appspot.com/api/counts"

  if (q == "") {
    req <- base.url
  } else {
    req <- paste(base.url, URLencode(q), sep = "/")
  }
  
  print(paste("Request:", req))
  return(fromJSON(getURL(req), unexpected.escape = "skip"))
}

admin.path <- function(...) {
  # Given an arbitrary number of levels, will return the appropriate
  # structure for the API call.

  ## Example usage:
  ##   > adminPath("idn", 2, 3)
  ##   "idn/2/3"
  filtered <- as.list(Filter(function(x) { !is.null(x) }, c(...)))
  return(do.call("paste", c(filtered, sep = "/")))
}

date.range <- function(begin = NULL, end = NULL) {
  ## Accepts a date range of the form "%Y-%m-%d" and returns an
  ## appropriately formatted date object.  Note that if a single date
  ## is supplied, then it is assumed that it is the beginning of the
  ## date range, and that the end is the most recent date.

  ## Example usage:
  ##   > dateRange(begin = "2005-12-01", end = "2008-04-14")
  ##   "?date=2005-12-01,2008-04-14"
  query.pre <- "?range="
  if (is.null(begin) && is.null(end)) {
    return("")
  } else if (!is.null(begin) && is.null(end)) {
    return(paste(query.pre, begin, sep = ""))
  } else if (!is.null(begin) && !is.null(end)) {
    return(paste(query.pre, begin, ",", end, sep = ""))
  } else {
    stop("You must supply a valid date range")
  }
}

agg.admin <- function(level = NULL) {
  ## Accepts a level for aggregation and returns the appropriately
  ## formatted query parameter
  if (!is.null(level)) {
    return(paste("?aggregate=", level, sep = ""))
  } else {
    return("")
  }
}

count.query <- function(iso = NULL, id1 = NULL, id2 = NULL, id3 = NULL,
                        aggregate.level = NULL, begin = NULL, end = NULL) {
  ## Accepts a specification of the desired data and returns a data
  ## frame of the panel data set

  ## Build the structured query and return the results
  admin <- admin.path(iso = iso, id1 = id1, id2 = id2, id3 = id3)
  agg   <- agg.admin(level = aggregate.level)
  date  <- date.range(begin = begin, end = end)
  q <- paste(admin, agg, date, sep = "")
  res <- query(q)

  .unnest <- function(entry) {
    date  <- entry$series[[1]][[1]]; count <- entry$series[[1]][[2]]
    list(iso = entry$iso, country = entry$country, date = date, count = count)
  }

  ## Return a panel data frame
  flat.list <- lapply(res$data[[1]]$series, .unnest)
  print(flat.list)
  table <- do.call(rbind.data.frame, flat.list)

  print(paste(nrow(table), "entries returned.", sep = " "))

  ## convert date string to R date object
  table$date <- as.Date(table$date)
  return(table)
}
