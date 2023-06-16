---
title: "SQS Simple Fair Queuing"
date: 2023-06-16T10:23:06+07:00
tags: ["AWS", "SQS", "Fair-queue"]
draft: false
---


In a system with different user workloads, fairness is a must, unless
you honestly want the big fish to consume all the resources and let
the smaller ones wait in line.

There are [many][0] fair-queuing algorithms out there, mostly constructed
to solve the fairness in network schedulers. But for simple web applications,
we only need a 2-queues system to solve the fairness problem:

- One priority queue, which handles messages selectively, is rate-limited by
a user basis
- One regular queue, which handles all the messages sequentially

Fortunately, AWS SQS comes with the dead-letter queues feature that fits
nicely in our use case. Let's create 2 queues, one dead-letter queue as the
regular queue, and another queue as the priority queue, with a redrive policy
that set max receive to 1 and dead-letter queue to the regular.

The fairness logic should be clear now:

- The first worker pulls messages from the priority queue, and checks if
it's rate limited. If not, go ahead and consume the message, otherwise,
put it back. Redrive policy will ensure the message is moved to the
dead-letter queue.

- The second worker will work on the dead-letter queue, which consumes
messages one by one.






[0]: https://en.wikipedia.org/wiki/Fair_queuing
[1]: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html
