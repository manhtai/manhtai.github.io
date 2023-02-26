---
title: "SQL: Group by Top 5"
date: 2023-02-22T17:31:03+07:00
tags: ["SQL", "Postgres"]
draft: false
---

Let's say we want to aggregate some data to make a trending bar chart of
orders made in the last month on the daily basis. Along with that, show the
top 5 most spent buyers, i.e. group by the top 5 buyers, with top 6 onward are
considered the "Other" group.

## Data Seeding

```sql
CREATE TABLE orders
(
    id     BIGINT       NOT NULL PRIMARY KEY,
    email  VARCHAR(255) NOT NULL,
    amount BIGINT       NOT NULL,
    date   TIMESTAMP    NOT NULL
);

INSERT INTO orders (id, email, amount, date)
VALUES (1, 'email1@example.com', 1000, '2023-01-01T00:00:00Z'),
       (2, 'email2@example.com', 2000, '2023-01-02T00:00:00Z'),
       (3, 'email3@example.com', 3000, '2023-01-03T00:00:00Z'),
       (4, 'email4@example.com', 3000, '2023-01-04T00:00:00Z'),
       (5, 'email5@example.com', 3000, '2023-01-05T00:00:00Z'),
       (6, 'email6@example.com', 3000, '2023-01-06T00:00:00Z'),
       (7, 'email7@example.com', 3000, '2023-01-07T00:00:00Z'),
       (8, 'email8@example.com', 3000, '2023-01-08T00:00:00Z'),
       (9, 'email9@example.com', 1000, '2023-01-09T00:00:00Z'),
       -- 3 orders of "Other" group
       (10, 'email10@example.com', 20, '2023-01-10T00:00:00Z'),
       (11, 'email11@example.com', 20, '2023-01-10T00:00:00Z'),
       (12, 'email12@example.com', 20, '2023-01-10T00:00:00Z'),
       -- 5 extra orders to make Top 5
       (13, 'email1@example.com', 300, '2023-01-05T00:00:00Z'),
       (14, 'email2@example.com', 300, '2023-01-06T00:00:00Z'),
       (15, 'email3@example.com', 300, '2023-01-07T00:00:00Z'),
       (16, 'email4@example.com', 300, '2023-01-08T00:00:00Z'),
       (17, 'email5@example.com', 300, '2023-01-09T00:00:00Z');
```

From the seeding data, we can see that the top 5 is from email1@example to
email5@example. And the Other group has 3 orders on a specific day.

## Query Steps

1. Find the Top 5 using the `ROW_NUMBER()` query, then join back with the
   original Orders table to change the email column: Top 5 emails stay as it
   is. Top 6 onward change to "Other"

2. Init the date buckets to join with grouped orders to count the orders by
   date.

And the final query is:

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
     ranks AS (SELECT email                                       AS email,
                      ROW_NUMBER() OVER (ORDER BY COUNT(id) DESC) AS email_rank
               FROM orders
               GROUP BY email),
     groups AS (SELECT id,
                       CASE WHEN r.email_rank <= 5 THEN o.email ELSE 'Other' END AS email,
                       date
                FROM orders o
                         LEFT JOIN ranks r ON o.email = r.email)
SELECT b.date      AS date,
       g.email     AS email,
       COUNT(g.id) AS count
FROM buckets b
         LEFT JOIN groups g ON b.date >= g.date AND b.date + INTERVAL '-1 day' < g.date
GROUP BY b.date, g.email
ORDER BY date;
```

## The Result

```
date,email,count
2023-01-01 00:00:00.000000,email1@example.com,1
2023-01-02 00:00:00.000000,email2@example.com,1
2023-01-03 00:00:00.000000,email3@example.com,1
2023-01-04 00:00:00.000000,email4@example.com,1
2023-01-05 00:00:00.000000,email1@example.com,1
2023-01-05 00:00:00.000000,email5@example.com,1
2023-01-06 00:00:00.000000,email2@example.com,1
2023-01-06 00:00:00.000000,Other,1
2023-01-07 00:00:00.000000,email3@example.com,1
2023-01-07 00:00:00.000000,Other,1
2023-01-08 00:00:00.000000,email4@example.com,1
2023-01-08 00:00:00.000000,Other,1
2023-01-09 00:00:00.000000,email5@example.com,1
2023-01-09 00:00:00.000000,Other,1
2023-01-10 00:00:00.000000,Other,3
```

As same as we expected it.
