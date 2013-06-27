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
    req <- paste(base.url, URLencode(q), sep = "")
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
  res <- do.call("paste", c(filtered, sep = "/"))
  if (length(res) != 0) {
    return(paste("/", res, sep = ""))
  } else {
    return(res)
  }
}

date.range <- function(begin = NULL, end = NULL) {
  ## Accepts a date range of the form "%Y-%m-%d" and returns an
  ## appropriately formatted date object.  Note that if a single date
  ## is supplied, then it is assumed that it is the beginning of the
  ## date range, and that the end is the most recent date.

  ## Example usage:
  ##   > dateRange(begin = "2005-12-01", end = "2008-04-14")
  ##   "?date=2005-12-01,2008-04-14"
  query.pre <- "range="
  if (is.null(begin) && is.null(end)) {
    return(NULL)
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
    return(paste("aggregate=", level, sep = ""))
  } else {
    return(NULL)
  }
}

count.params <- function(aggregate.level = NULL,
                         begin = NULL, end = NULL) {
  ## Constructs the parameter string for the URL query
  agg   <- agg.admin(level = aggregate.level)
  date  <- date.range(begin = begin, end = end)
  params <- paste(na.omit(c(agg, date)), collapse = "&", sep = "")
  if (params == "") {
    return(NULL)
  } else {
    return(paste("?", params, sep = ""))
  }
}

convert.entry <- function(entry) {
  ## Accepts a list entry from the JSON conversion of an
  ## administrative unit and the series associated with it.  Returns a
  ## data frame sorted by date for that unit.
  temporal <- do.call(rbind.data.frame, entry$series)
  names(temporal) <- c("date", "count")
  unit <- rbind(entry[-1])
  data <- data.frame(unit, temporal)
  return(data[sort(data$date),])
}

count.query <- function(iso = NULL, id1 = NULL, id2 = NULL, id3 = NULL,
                        aggregate.level = NULL, begin = NULL, end = NULL) {
  ## Accepts a specification of the desired data and returns a data
  ## frame of the panel data set

  ## Build the structured query and return the results as a list,
  ## converted from the JSON object
  admin <- admin.path(iso, id1, id2, id3)
  params <- count.params(aggregate.level, begin, end)
  q <- paste(na.omit(c(admin, params)), collapse = "")
  res <- query(q)

  ## Bind the time series by unit into a panel and return the panel.
  panel <- do.call(rbind, lapply(res$data, convert.entry))
  print(paste(nrow(panel), "entries returned.", sep = " "))
  return(panel)
}
