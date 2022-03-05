---
title: "Redshift for customer-facing apps"
date: 2022-03-02T19:08:23+07:00
tags: ["AWS", "Redshift"]
draft: false
---

[Redshift][1] is an OLAP database from AWS, so for data warehouse purpose, it's
a viable option. The question is, can we use it as an OLTP database for
customer-facing applications?

Short answer: No, for generic OLTP use case, and Yes for specific functions,
such as analytics or building dashboards. The reasons are, firstly, analytic
jobs usually do aggregation on a large chunk of data which would run very slow
on row-based OLTP databases, and secondly, analytic features are usually the
low traffic parts on the system. Those requirements align very well with
Redshift features.

## 1. Concurrency connections

As of now, Redshift [supports][2] up to 50 concurrency connections by default.
Although we can get [concurrency scaling][3] feature by paying more, we need
to keep the query latency in the 1-5 seconds range to be usable. Let's say we
get an average of 1 second per query, then we can serve up to 50 requests per
second (RPS), if the analytic APIs only serve 10 RPS, then we're good to go.


## 2. Query latency

The catch now is how will we keep our query latency to only seconds, or
even better, sub-second? Redshift is very powerful, but for a huge amount of
data, it must be tuned correctly for fast queries.

Enter the Redshift's DIST key and SORT key couple!

Since Redshift is a columnar database and is designed to keep a massive
volume, it doesn't have indexes as normal database, it only has 2 kinds of
key for distributing and sorting data into desired locations.

- DIST key: for distributing data between compute nodes. It will affect
  joins and aggregations performance. We should choose a high cardinality
  column for this key.

- SORT key: for sorting data on disk. It will affect your "where" performance.
  There are 2 types of sort key: COMPOUND and INTERLEAVED, but we can only
  choose only one of them for the table sort key.

Refer to AWS best practice for designing table [here][4].


## 3. Benchmark

We've done some benchmarks using [k6][5] on our toy APIs that use Redshift
ra3.xlplus (4 vCPU, 32 GB RAM, 3 compute nodes) as the main database and the
results are as good as promised: if you keep your query latency to 1 second,
you get 50 RPS, if it goes down to 500 ms, you get 100 RPS.

The math works out!


[1]: https://aws.amazon.com/redshift/
[2]: https://docs.aws.amazon.com/redshift/latest/dg/cm-c-defining-query-queues.html#cm-c-defining-query-queues-concurrency-level
[3]: https://docs.aws.amazon.com/redshift/latest/dg/concurrency-scaling.html
[4]: https://docs.aws.amazon.com/redshift/latest/dg/c_designing-tables-best-practices.html
[5]: https://k6.io/
