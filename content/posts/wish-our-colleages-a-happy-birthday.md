---
title: "Wish our colleages a happy birthday"
date: 2018-02-12T22:04:15+07:00
tags: ["bot", "metabase", "slack"]
draft: false
---

We build an intranet app using Django to help HR manage people at work. And
since we use Metabase for all our analysis tasks, we got the HR database to
query all the things about our colleages (not the salary though, it's
accounting's matter).

I'm not interested in my colleages' days of leave, but I wish they got a happy
birthday, so why don't we send out a wish, automatically?

I wrrite a question in SQL, it's just as simple as list out all people who has
date and month equal to today's date and month. And use a [bot][1] to check
the question everyday at 10am, then send out a wish if the question is not
empty.

The tricky part is we don't know firsthand what should be included in the
message, like our colleages' name, slack id, etc. So I have to evaluate them
at running time. The solution is to pass a string to alert message and then
convert it to string interpolation later. Like this:

```js
// When creating alert
const originalMessage = "Happy birthday to ${rows.join(", ")}!";

// At running time
const rows = ["some", "data"];
const theMessage = eval('`' + originalMessage + '`');
sendMessageToSlack(theMessage);
```

I know it's extremely risky to use `eval()` anywhere, so I use [safe-eval][2]
instead. Although at the moment it has a security [bug][3], it should be fine
for our internal use, at least for now.


[1]: /posts/metabase-alerts
[2]: https://github.com/hacksparrow/safe-eval
[3]: https://github.com/hacksparrow/safe-eval/issues/5
