---
title: "Sort by multiple keys in Golang"
date: 2022-08-09T17:14:17+07:00
tags: ["Go"]
draft: false
---


## Problem:

We have a list of users:

```go
type User struct {
    Name  string
    Valid bool
    Age   int
}

listUsers := []User{
    {
        Name:  "A",
        Valid: false,
        Age:   12,
    },
    {
        Name:  "B",
        Valid: true,
        Age:   11,
    },
    {
        Name:  "C",
        Valid: true,
        Age:   10,
    },
    {
        Name:  "D",
        Valid: false,
        Age:   13,
    },
}
```

We want to sort by `Valid` first, then `Age` in descending order.
The solution should be `B C D A`.


## Wrong solution:


```go
sort.Slice(listUsers, func(i, j int) bool {
    if listUsers[i].Valid && !listUsers[j].Valid {
        return true
    }

    return listUsers[i].Age > listUsers[j].Age
})
```

This solution returns `D B C A`.


## Right solution:


```go
sort.Slice(listUsers, func(i, j int) bool {
    if listUsers[i].Valid != listUsers[j].Valid {
        return listUsers[i].Valid && !listUsers[j].Valid
    }

    return listUsers[i].Age > listUsers[j].Age
})
```

This solution returns `B C D A`. As expected.

## How so?

The wrong one forgot the case when `listUsers[i].Valid` is `false` and
`listUsers[j].Valid` is `true`. It should return `false` in that case
instead of fallback to `Age` comparision.
