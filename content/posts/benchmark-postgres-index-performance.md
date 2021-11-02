---
title: "Benchmark Postgres Index Performance"
date: 2021-11-02T14:42:35+07:00
tags: ["Postgres", "Benchmark"]
draft: false
---


## The question

We had a table contains 150.000 rows and 6 text columns. We do some `select`
query using exact match by each of the columns. 150k rows is not too much for
indexing all the 6 columns, right? Let's do a benchmark!


## The benchmark


### 1. Create table

```sql
CREATE TABLE bench AS
SELECT
    md5(random()::text) AS a,
    md5(random()::text) AS b,
    md5(random()::text) AS c,
    md5(random()::text) AS d,
    md5(random()::text) AS e,
    md5(random()::text) AS f
FROM
    generate_series(1,150000);
```


### 2. Select without index

```sh
echo "select * from bench where a = 'a' and b = 'b' and c = 'c' and d = 'd' and e = 'e' order by f limit 1;" | pgbench -d postgres -t 50 -P 1 -f -
```

Result:

```
latency average = 23.562 ms
latency stddev = 0.946 ms
```

### 3. Create index

```sql
create index bench_a on bench(a);
```

The way you choose indexes here depends on the cardinality or uniqueness of the data.
We use random data here so one index is enough, and it will perform almost exactly as
when you index all 6 columns!


### 4. Select with index

```sh
echo "select * from bench where a = 'a' and b = 'b' and c = 'c' and d = 'd' and e = 'e' order by f limit 1;" | pgbench -d postgres -t 50 -P 1 -f -
```

Result:

```
latency average = 0.357 ms
latency stddev = 0.354 ms
```

## The answer...

...is yes. Indexing makes your queries 66 times faster!
