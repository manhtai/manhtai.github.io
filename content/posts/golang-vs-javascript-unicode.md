---
title: "Handle Unicode in Golang and Javascript"
date: 2022-05-17T16:51:30+07:00
tags: ["Golang", "Javascript"]
draft: false
---

Currently I'm working on some basic security stuffs between server side written
in Golang and client side written in, well, Javascript.


## Code point

A character is not the same as a code point.

The Unicode standard uses the term "code point" to refer to the item represented
by a single value. A character may be represented by a number of different
sequences of code points, and therefore different sequences of UTF-8 bytes.

In Go, a code point is called `rune`, when using `range` on a string, it will
result in a rune at a time. Read more about strings in Go [here][0].

In Javascript, when using `String.prototype.split()`, it will result in a UTF-16
code unit. To separate the text into code points, use `for..of` or `Array.from`
instead. Read more about string split in Javascript [here][1]. To get UTF-16
code unit, use `String.prototype.charCodeAt()`, to get code point, use
`String.prototype.codePointAt()`.


## Escape Unicode characters

When working with Unicode strings in cryptography, we wouldn't want to deal
with vary size code point in Unicode characters. To make our life easier,
escape them first, and then working on ASCII.

In Golang, we have `url.QueryEscape()` and in Javascript, we got
`encodeURIComponent()`.

`url.QueryEscape()` escapes the string so it can be safely placed inside a
URL query.

The `encodeURIComponent()` function encodes a URI by replacing each instance
of certain characters by one, two, three, or four escape sequences representing
the UTF-8 encoding of the character.

So in theory, `encodeURIComponent()` and `QueryEscape()` should be the same,
but in practice, they are not. Both of them try to follow [RFC 3986][2] until
they don't. Depend on what you are working on, they might behave the same on
the same kind of string. So you can use `QueryEscape()` on server side and
`decodeURIComponent()` on client side with a high level of confidence.



[0]: https://go.dev/blog/strings
[1]: https://stackoverflow.com/questions/4547609
[2]: https://datatracker.ietf.org/doc/html/rfc3986
