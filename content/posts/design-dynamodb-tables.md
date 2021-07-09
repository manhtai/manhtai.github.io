---
title: "Design DynamoDB Tables"
date: 2021-07-05T16:27:58+07:00
tags: ["AWS", "DynamoDB", "Go"]
draft: false
---

## Primary key & Indexes

DynamoDB is a NoSQL database, so in theory, you can store all kinds of
objects. The catch is you can specify the key to partition the data, so 
you can scale out your applications horizontally, in proportion to the
numbers of partitions.

There are two kinds of primary keys in a DynamoDB table, of which you 
can only choose to implement one:

- **Hash key only**: The hash key is also the partition key, which must
  be globally unique.
- **Hash key with a range key combination**: The hash key is the 
  partition key, which is not required to be unique, but the combination,
  i.e. the primary key must be.

Whichever kind of primary key you choose, the scalability is the same.
To make it works, make sure your hash keys are distributed equally in all
partitions.

Besides the primary key, DynamoDB supports global secondary indexes and local
secondary indexes, so you can make your queries run fast in other dimensions
also.

## An example in Go

[dynamo][1] is a Golang library that makes it extremely easy to define the primary
key and indexes.

Let's define a `Job` table with a primary key as the combination of `ShardId`
and `Token`, in which `ShardId` is a hash key, and `Token` is a range key:


```go
type Job struct {
	ShardId      int               `dynamo:"shard_id,hash"`
	Token        string            `dynamo:"date_token,range"`
	Name         string            `dynamo:"name"`
	CreatedAt    time.Time         `dynamo:"created_at"`
}
```

Now to create the table, we init a DynamoDB session and create the table:


```go
session, _ := session.NewSession()
config := aws.NewConfig()
client := dynamo.New(session, config)

client.CreateTable(`Job`, Job{}).Run()
```

To query the jobs in a specific shard:

```go
var jobs []*Job
client.
    Table(`Job`).
    Get("shard_id", shardId).
    Filter("'token' < ?", tokenId).
    Limit(100).
    All(&jobs)
```




[1]: https://github.com/guregu/dynamo/
