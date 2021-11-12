---
title: "Distribute workload between ECS tasks"
date: 2021-08-19T14:04:41+07:00
tags: ["AWS", "ECS", "Go"]
draft: false
---

If your ECS tasks are receiving traffic from a load balancer then the workload
will be equally distributed between them. How about when we are using ECS
tasks as a worker farm to handle long running jobs? And say, we want some
workers to work on some partitions of the data but not all of them? Then each
ECS task must know their identity and the number of tasks that belong to the
same service as well.


## 1. Get task ARN

With `${ECS_CONTAINER_METADATA_URI_V4}/task` endpoint, we can get the task ARN
and metadata about its cluster and family. The docs are [here][2].

After sending a GET request from our container, we got:

```
{
    "Cluster": "default",
    "TaskARN": "arn:aws:ecs:us-west-2:111122223333:task/default/158d1c8083dd49d6b527399fd6414f5c",
    "Family": "curltest",
    ...
}
```

This request doesn't require any authentication at all, as long as we send it
from our ECS task.


## 2. List all tasks in the same service


With `Cluster` and `Family` of a task, we can list all running tasks in
a service using ECS API, in this example we will use Go SDK though:


```Go
list := ecsClient.ListTasks(context.TODO(), &ecs.ListTasksInput{
	Cluster:       "default",
	Family:        "curltest",
	DesiredStatus: types.DesiredStatusRunning,
})
```

`list.TaskArns` contains all ARN of tasks in the service, including the task
making the request. This request does require authentication nevertheless.


## 3. Distribute the workload


Now we know how many tasks we got, the problem becomes [easy][1].


[1]: /posts/restart-golang-goroutines
[2]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint-v4.html
