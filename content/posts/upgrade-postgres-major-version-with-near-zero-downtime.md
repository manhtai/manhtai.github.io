---
title: "Upgrade Postgres major version with near-zero-downtime"
date: 2022-06-20T07:32:27+07:00
tags: ["Postgres", "AWS"]
draft: false
---

Our system have a typical facing API and some workers which do jobs on the
background. All of them have read/write access to the Postgres instance. Our
instance is not very big, but when we try to upgrade using AWS console on the
clone, it takes more than 20 minutes and that's not acceptable.
Hence we were looking elsewhere, and find [a solution][1] from AWS using DMS.
It worked out pretty well for us.


## Step by step

1. Clone a new instance from our current database, truncate all tables and
   upgrade the new database to the latest version.

2. Full load and then CDC sync between the old database and the new one.
   Monitor the latency as well as table statistics.

3. Stop all writing tasks (API & workers) to old database.

4. Stop DMS job.

5. Switch database connection to the new one and restart all writing tasks.

6. Verify, then clean up old resources.


## Catches

Current DMS engine (3.4.6) has some problems with some column types. But we
can resolve them quickly thanks to clear error logs:

  - `varchar` (without n), we have to convert it to `text`
  - `jsonb not null`, we have to make it nullable


But in overall the upgrade process is smooth, we still got some downtime but
it's insignificant.


[1]: https://aws.amazon.com/blogs/database/achieving-minimum-downtime-for-major-version-upgrades-in-amazon-aurora-for-postgresql-using-aws-dms/
