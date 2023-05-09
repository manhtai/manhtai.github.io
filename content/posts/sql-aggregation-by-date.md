---
title: "SQL: Aggregation by Date"
date: 2023-05-09T15:53:36+07:00
tags: ["SQL", "Postgres"]
draft: false
---

In previous post about [group by top 5][1], we're trying to find the top
5 buyers on a daily basis and we're using the date bucket technique to
aggregate data for each day, like this:


```sql
WITH buckets AS (SELECT '2023-01-01T00:00:00Z'::TIMESTAMP as date
                 UNION
                 SELECT '2023-01-02T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-03T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-04T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-05T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-06T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-07T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-08T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-09T00:00:00Z'::TIMESTAMP
                 UNION
                 SELECT '2023-01-10T00:00:00Z'::TIMESTAMP),
[...]
FROM buckets b
         LEFT JOIN groups g ON b.date >= g.date AND b.date + INTERVAL '-1 day' < g.date
GROUP BY b.date, g.email
ORDER BY date;
```

This query works. But the problem is we have to do a JOIN between `buckets`
and `groups`. If `groups` is a very big table then the query will be too slow
to run. For big data in general, not moving data around is the key to boost
the query performance.

Let's make the above query better by not JOINing the big table with others
(hence not moving it). Instead try to aggregate the data in-place.


```sql
WITH dates AS (SELECT id,
                      DATE_TRUNC('day', date) as date,
                      email,
                      amount
               FROM orders),
     ranks AS (SELECT email                                       AS email,
                      ROW_NUMBER() OVER (ORDER BY COUNT(id) DESC) AS email_rank
               FROM dates
               GROUP BY email),
     groups AS (SELECT id,
                       CASE WHEN r.email_rank <= 5 THEN o.email ELSE 'Other' END AS email,
                       date
                FROM dates o
                         LEFT JOIN ranks r ON o.email = r.email)
SELECT date,
       email,
       COUNT(id) AS count
FROM groups
GROUP BY date, email
ORDER BY date;
```


The result should be the [same][1], but without any JOINs, hence it runs way faster.




[1]: /posts/sql-group-by-top-5
