---
title: "Week 1: Birthday Attacks"
date: 2018-03-27T23:04:47+07:00
draft: true
tags: ["crypto"]
---

Birthday paradox:

> In a set of n randomly chosen people, some pair of them will have the same
> birthday. By the pigeonhole principle, the probability reaches 100% when
> the number of people reaches 367 (since there are only 366 possible
> birthdays, including February 29). However, 99.9% probability is reached
> with just 70 people, and 50% probability with 23 people.

You can read the full calculation in [Wikipedia][1]. It has some nice
approximations, too, but a more easy one is if there are $ N $ different
values you can take, then after $ \sqrt{N} $ values, you can expect a collision.

So if a financial system use 64-bit authentication key for each transaction,
we will expect a collisions just after $ 2^{32} $ transactions.


[1]: https://en.wikipedia.org/wiki/Birthday_problem
