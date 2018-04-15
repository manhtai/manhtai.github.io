---
title: "Memory Leak in Celery"
date: 2018-04-15T10:51:06+07:00
draft: false
tags: ["celery", "ecs", "docker"]
---

Turn out Celery has [some memory leaks][1]. We don't know that beforehand.
After deploying some Celery servers using AWS ECS we notice that all Celery
tasks will consume most of the server memory and then become idle.

My first attempt was set [hard limit][2] for container memory to 1GiB. And
guess what? Celery will consume 99.9% of that limit then become idle after
some times. It's good for the server but doesn't solve our problem.

My second attempt was set `CELERYD_TASK_TIME_LIMIT` to 300, so celery tasks
will be killed after 5 minutes no matter what. This time Celery continue to
take memory percentage as much as it can and then become inactive, but after
5 minutes it kills all the tasks to release memory and then back to work
normally.

I can't say I'm satisfied with this solution, but it works for now. Till next
time.




[1]: https://github.com/celery/celery/issues/1427
[2]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
