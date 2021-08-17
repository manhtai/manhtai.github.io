---
title: "Some first lessons in Go"
date: 2021-08-17T10:02:17+07:00
tags: ["Go"]
draft: false
---

Recently I switched to a job in which I am working mostly with the Go
language. Besides knowing the tiny set of syntax and the old-style
language flow, I've learned some first lessons when writing Go.


## 1. Composition and interfaces are everywhere

We use composition because we should prefer composition over
inheritance and also because Go doesn't have inheritance at all!

Go does have interfaces instead, and we use them to make our code more
abstract and easier to test. The thing I don't really like about them
is conforming to an interface is implicit, so we need help from our
IDE to know exactly which interfaces our structs are implementing.


## 2. Using Goroutines is not a trivial task

The most important lesson I've learned is never firing up an arbitrary
number of Goroutines. You should limit them by using a fan-out pattern
with a determined set of workers instead.

The second lesson is when not working, the Goroutines should not
consume any CPU resource, if they are, something must be wrong.


## 3. Go is not thread-safe by default

Go is fast, it can do many things at once, but we must be careful with
it or some nasty data result will come up and you don't know why.

This brings us to the last lesson.


## 4. Stress testing, benchmarking, and profiling help

Go is shipped with default benchmarking & profiling tools and even more
excellent community libraries to do the job. Learn to use them properly,
and never skip the stress test phase before launching your app.


### Conclusion

Go is fun, easy to get started, run fast, and have a small footprint,
but it won't keep you from shooting yourself in the foot. So enjoy
writing the code, but never put 100% faith in them :)
