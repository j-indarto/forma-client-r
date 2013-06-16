Access the FORMA data from R
==============

The objective of this small project is to allow easy access to the
FORMA data from within R.  The API sill only supports aggregated FORMA
counts for administrative boundaries; and this project appropriately
structures requests from R for the aggregated counts by administrative
unit and time period.

Consider, for example, a query to return the number of FORMA alerts
within Indonesia for each interval after January 1, 2008:

```R
> x <- dataQuery(iso = "idn", begin = "2008-01-01")
[1] "Request: http://localhost:8080/api/counts/idn?date=2008-01-01"
> head(x)
          date  sum iso
2   2008-11-15 1712 IDN
210 2006-10-15 3522 IDN
3   2010-06-25 1335 IDN
4   2006-03-05 1588 IDN
5   2006-03-21 1498 IDN
6   2011-11-16 2076 IDN
```
