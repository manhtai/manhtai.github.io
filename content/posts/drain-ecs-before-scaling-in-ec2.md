---
title: "Drain ECS instances before scaling down in EC2"
date: 2018-05-21T17:33:18+07:00
tags: ["AWS", "ECS", "Go"]
draft: false
---

## The problem

We have 2 independent auto scaling systems: EC2 auto scaling groups which
scales instances number & ECS auto scaling which scales tasks number. This
setup may work fine when scaling up. Still, if new tasks need more instances
to start up, it must wait for them, but it's ok to wait a little.

But things soon become disaster when EC2 instances terminates **before**
ECS tasks draining out.

Actually, ECS instances will not auto drain to be ready for terminating
instances in EC2, so don't expect anything. We have to set that up manually.

## The solution

An AWS official [blog][1] shows us how to do this, and it has a nice demo for
newly created EC2 & ECS setup. But what if we just want to set up for our
running ECS instances? Here it is.

Firstly, make sure you know what [lifecycle hooks][2] are. Then follow these
steps:

- 1, Create a lambda function using this [script][3]. It is my fork of AWS
  sample [script][4], but sucks less.

- 2, Set role for our lambda function to have these permissions:

```
- autoscaling:CompleteLifecycleAction
- logs:CreateLogGroup
- logs:CreateLogStream
- logs:PutLogEvents
- ec2:DescribeInstances
- ec2:DescribeInstanceAttribute
- ec2:DescribeInstanceStatus
- ec2:DescribeHosts
- ecs:ListContainerInstances
- ecs:SubmitContainerStateChange
- ecs:SubmitTaskStateChange
- ecs:DescribeContainerInstances
- ecs:UpdateContainerInstancesState
- ecs:ListTasks
- ecs:DescribeTasks
- sns:Publish
```

- 3, Setup an SNS trigger for the function, choose a name for it.

- 4, Setup a service role so Auto Scaling Groups can push to SNS, using [this
   guide][5]. (This is quite interesting because you have to set up a role so
   that a service will have some kind of permission).

- 5, Create a lifecycle hook by CLI, since the **GUI is not fully supported
   yet**:

```
aws autoscaling put-lifecycle-hook
  --lifecycle-hook-name EcsWebScaleDown
  --auto-scaling-group-name ecs-web
  --lifecycle-transition autoscaling:EC2_INSTANCE_TERMINATING
  --heartbeat-timeout 900
  --notification-target-arn arn:aws:sns:ap-southeast-1:XXXXXXXXXXXX:EcsInstanceDrain
  --role-arn arn:aws:iam::XXXXXXXXXXXX:role/AutoScalingNotificationRole
```

It should be good now, as advertised :)

[1]: https://aws.amazon.com/blogs/compute/how-to-automate-container-instance-draining-in-amazon-ecs/
[2]: https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html
[3]: https://gist.github.com/manhtai/66dfdae56ebce7b6270788018516a409
[4]: https://github.com/aws-samples/ecs-cid-sample/blob/master/code/index.py
[5]: https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html#sns-notifications
