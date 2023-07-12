---
title: "Big Data Aggregation Strategy"
date: 2023-07-12T16:46:24+07:00
tags: ["SQL"]
draft: false
---

We collect data in raw form and then display them in aggregations.
That's the most basic form of data analytics. Writing data aggregation
queries should be a trivial task. The catch is when data got big, we
can't do real-time aggregations on raw data anymore. And the solution
is to do pre-aggregation beforehand.

This post sketches out a simple plan that may suit many use cases that
are in need of pre-aggregations.

## 1. Examination worker

This worker examines the raw data for objects that need to run the
aggregations on. This should be a cron job that triggers after a fixed
time range, based on your requirements for aggregation freshness. The
examination worker will create a `queued` task in the task queue table
for the aggregation worker to work on.

A not-so-minor issue here is raw data may arrive after or before the
examining time. So once in a while, we need to trigger a back-fill job
that will do the data missing hunt.

## 2. Aggregation worker

This worker pulls the tasks from the task queue table, changes the
status from `queued` to `started`, and then works on the real aggregation
job. After done with it, change the `started` to `completed`. The status
change is a kind of optimistic lock mechanism that we will ensure by
setting the where condition when updating the value. Something like this:

```sql
UPDATE task_queue
SET status = 'completed'
WHERE status = 'started'
```

For aggregation data, new aggregated rows will replace the olds.
We handle the switch by using 2 extra columns: `valid` and `aggregation_time`.
The invalidation will look like this:

```sql
UPDATE agg_table
SET valid = CASE WHEN aggregation_time < $1 THEN FALSE ELSE TRUE END
```

## 3. Clean-up worker

This worker will work like a vacuum, cleaning out completed tasks and
invalidated aggregation rows.
