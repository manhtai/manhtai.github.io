---
title: "Partial update nullable fields in Go"
date: 2022-01-05T19:19:55+07:00
tags: ["Go", "SQL"]
draft: false
---

Using pointers and SELECT before UPDATE, we [solved][1] the partial
update problem, but leave out a minor detail: how do we set nullable
fields to NULL when the pointer will be `nil` whether we set it to
`null` or `undefined` (i.e. not send the field at all)?

**Answer**: Use blank value as null value!

Let's say we got a struct like this:


```go
type Student struct {
    Name        *string
    OnboardedAt *time.Time
}
```


## 1. For null string

To set the `Name` field to NULL, set it to an empty string and update
the field to NULL when that condition is satisfied. Simple enough.


## 2. For null time

To set `OnboardedAt` field to NULL, set it to empty string, and your
code will... panic! Because an empty string is not a valid time. It's
a little bit tricky here because time doesn't have a "blank" value,
but fortunately, it has a zero one.

Let's create a custom blank time instead:


```go
type BlankTime struct {
    time.Time
}

func (n *BlankTime) UnmarshalJSON(b []byte) (err error) {
    if string(b) == `""` {
        zero := time.Time{}
        *n = BlankTime{zero}
        return
    }

    tt, err := time.Parse(`"`+time.RFC3339+`"`, string(b))
    *n = BlankTime{tt}
    return
}
```

And rewrite our struct:

```go
type Student struct {
    Name        *string
    OnboardedAt *BlankTime
}
```

Now whenever we set the time field to an empty string, it will
get a zero value, do a check to set NULL for your time field.


[1]: /posts/golang-update-partially-and-return-fully/
