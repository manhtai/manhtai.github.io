---
title: "Optimize Redshift Query Using Window Functions"
date: 2023-12-14T22:26:56+07:00
tags: ["AWS", "SQL", "Redshift"]
draft: true
---

When writing queries to aggregate big data on Redshift, a normal JOIN can hurt
performance. Instead, consider converting them into window functions.
Even though window functions may run slower than JOINs on small datasets, they
can perform better on larger ones.

Let's dive into an example on email tracking events. Each subscriber will have
send, deliver, open, and click events in a typical email-sending cycle. The
first email provider sends the email, gets it delivered, subscribers open
the email, and click some links in it. Like so:

```csv
Email               Event name   Event time
first@example.com   send         2023-01-01 01:00:00
first@example.com   deliver      2023-01-01 01:01:00
first@example.com   open         2023-01-01 05:00:00
```

Will will want to display a list of subscribers that opened a particular
email with a specific timestamp for previous events. Like this:


```csv
Email              Send time            Delivery time        Open time
first@example.com  2023-01-01 01:00:00  2023-01-01 01:01:00  2023-01-01 05:00:00
```


## Naive version

```sql
SELECT
  MAX(CASE WHEN event_name = 'send' THEN event_time END)    AS send_time,
  MAX(CASE WHEN event_name = 'deliver' THEN event_time END) AS delivery_time,
  MAX(CASE WHEN event_name = 'open' THEN event_time END)    AS open_time,
FROM events
WHERE email IN (
  SELECT email
  FROM events
  WHERE event_name = 'open'
)
```


## Window version

```sql
SELECT
  MAX(CASE WHEN event_name = 'open' THEN event_name END)    AS event_name2,
  MAX(CASE WHEN event_name = 'send' THEN event_time END)    AS send_time,
  MAX(CASE WHEN event_name = 'deliver' THEN event_time END) AS delivery_time,
  MAX(CASE WHEN event_name = 'open' THEN event_time END)    AS open_time,
FROM events
WHERE event_name2 = 'open'
```
