---
title: "Restart Golang Goroutines"
date: 2021-11-12T10:48:34+07:00
tags: ["Go"]
commentid: 4
draft: false
---

In some cases such as [distributing the workload between ECS tasks][1], we need to
restart our workers, which are Goroutines in our case, base on the number of
ECS tasks to reassign partitions to the Goroutines on the same task.

Suppose we got 100 database partitions, if we had 1 ECS task, then all the
workers on that task will be responsible for all 100 partitions. But when we
scale the service to 20 ECS tasks, each task will be responsible for only
5 partitions, hence we need to restart the Goroutines and assign them
5 partitions only.

How would we do that? Here it is:


```go
func (w *worker) run(ctx context.Context) {
	partitions := make(chan []int)

	// Partition worker
	go w.partitionWorker.start(ctx, partitions)

	// Variable to cancel context
	var partCtx context.Context
	_, partCancel := context.WithCancel(ctx)

	for {
		select {
		case parts := <-partitions:
			partCancel()
			partCtx, partCancel = context.WithCancel(context.TODO())
			go w.jobWorker.start(partCtx, parts)

		case <-ctx.Done():
			partCancel()
			// Wait for jobWorker to finish
			time.Sleep(3 * time.Second)
			return
		}
	}
}

```

- `partitionWorker` is in charge of determining the partitions that the current
  ECS tasks need to work on, see the guide on how to do it [here][1].

- `jobWorker` is the one that does the heavy lifting on specific partitions
  and will be restarted whenever the partitions change.



[1]: /posts/distribute-workload-in-ecs-tasks
