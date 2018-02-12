---
title: "Metabase alerts"
date: 2018-01-27T16:26:24+07:00
tags: ["slack", "metabase", "bot"]
draft: false
---

[Metabase][1] is a simple and powerful BI tool for business. We use it to get
insights about almost everything that happens in our system. In [recent][2]
version it added alerts feature to question, but has some limitations.

Firstly, the shortest time it allows checking for something bad may happen is
one hour. It may seem acceptable in some business model but not ours. We need
at most 5 minutes delay time in alerting.

Secondly, we can't customize Slack alert format, and it sucks most of the
time.

Lastly, I don't know whether it's a bug or not, but sometime the alerts just
stop working!

Fortunately, Metabase has a [rich][3] API for frontend part, and we can use
that to make our own alert system.

So our solution is use a Slack bot to call the question API periodically, and
send a message to a choosen channel if the response is not empty.

Checkout the sample code [here][4].


[1]: https://metabase.com
[2]: https://metabase.com/blog/Metabase-0.27/index.html
[3]: https://github.com/metabase/metabase/blob/master/docs/api-documentation.md
[4]: https://github.com/manhtai/mimi/blob/master/metabase.js
