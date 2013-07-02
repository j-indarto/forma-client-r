Access the FORMA data from R
==============

The objective of this small project is to allow easy access to the
FORMA alerts from within R.  Consider, for example, a query to return
the number of FORMA alerts within Indonesia for each interval after
March 1, 2013:

```R
> (data <- count.query(iso = "idn", begin = "2013-03-01"))
[1] "3 entries returned."
```

The returned data frame reports the number of FORMA alerts within all
of Indonesia for the corresponding date:

```R
  iso   country       date count
1 IDN Indonesia 2013-03-06  1875
2 IDN Indonesia 2013-03-22  1952
3 IDN Indonesia 2013-04-07  1868
```

The API also supports different levels of aggregation. The following
query will report the same information as the previous query, but
disaggregated to the province level.

```R
> data <- count.query(iso = "idn", aggregate.level = 1, begin = "2013-03-01")
[1] "81 entries returned."
```

There are 81 entries returned, three for each of the 27 provinces in
Indonesia.

```R
> head(data)
  iso   country            name1 id1       date count
1 IDN Indonesia Kalimantan Timur  16 2013-03-06   171
2 IDN Indonesia Kalimantan Timur  16 2013-03-22   149
3 IDN Indonesia Kalimantan Timur  16 2013-04-07   135
4 IDN Indonesia       Yogyakarta  33 2013-03-06   171
5 IDN Indonesia       Yogyakarta  33 2013-03-22     1
6 IDN Indonesia       Yogyakarta  33 2013-04-07     1
```

