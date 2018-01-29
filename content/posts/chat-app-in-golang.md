---
title: "Build a distributed chat app in Golang"
date: 2018-01-29T21:19:23+07:00
draft: true
---

I've built a [demo][1] chat app in Go before, using Go channels to broadcast
messages, data is saved to MongoDB. It's quite a fun learning experience,
but when you want a chat app at scale, you need more. Yes I am looking at
you: **microservices**.

Now I know one thing or two about microservices and distributed systems,
I think at least these three are in need:

- 1. A service for saving messages to DB
- 2. A service for handling messages from clients
- 3. A proper message queue, for the talkings between services

Now we'll start to build one.


[1]: https://github.com/manhtai/golang-mongodb-chat
