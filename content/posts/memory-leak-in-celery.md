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

I thought it worked, but it didn't.

After running for some periods, Celery still hung. So it's not due to the leak
anymore. Continue digging around, I found out the main reason Celery hangs is
due to [some thread locks][4] caused by [neo4j python driver][5]. And that can
only be solved completely by changing the way neo4j driver save & fetch data
to async, which is still [an open issue][6] on GitHub. Although people gave
some temporary solutions to the problem, it's only apply for Python3, and our
project is still Python2. Hence, a [transition][7] from Python2 to Python3 is
needed.

In the mean time, I set up a cronjob to restart Celery after some times to
remove the lock.


[1]: https://github.com/celery/celery/issues/1427
[2]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
[3]: https://stackoverflow.com/a/33936673/4400989
[4]: https://github.com/celery/celery/issues/2917
[5]: https://github.com/neo4j/neo4j-python-driver
[6]: https://github.com/neo4j/neo4j-python-driver/issues/180
[7]: /posts/python-2to3-transition
