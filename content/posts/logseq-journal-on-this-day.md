---
title: "Logseq journal: On this day"
date: 2022-02-25T12:12:00+07:00
tags: ["logseq"]
draft: false
---

Recently I [moved][1] my journals to [Logseq][2] and I like it very much.
I use it almost everyday now. Core features are good, and the plugins market
place surpasses my expectation.

Oh and I've written journals for the last 6 years, sometimes I want to know on
this day of some years before, what was happenning and what was I thinking. Lo
and behold, Logseq has advanced queries feature for just that!

Create new page and paste this content into it:

```
#+BEGIN_QUERY
{:title "On this day some years before"
 :query [:find (pull ?b [*])
       :in $ ?today
       :where
       [?b :block/page ?p]
       [?p :page/journal-day ?d]
       [(str ?d) ?ds]
       [(subs ?ds 4 8) ?md1]
       [(str ?today) ?td]
       [(subs ?td 4 8) ?md2]
       [(= ?md1 ?md2)]
       [(< ?d ?today)]
]
:inputs [:today]}
#+END_QUERY
```

Logseq use [Datascript][3] for database and [Datalog][4] for query engine.
What I've done above can be translated to normal language as:

- Scan all pages, in each page, get the journal date attribute.
- Convert that attribute to string, you will get something like "20220225"
  which is in "yyyyMMdd" format.
- Take just the "MMdd" part, and compare that part with today's "MMdd".
- Return all blocks that match today's and having the date less than today.



[1]: /posts/bye-google-hi-apple
[2]: https://github.com/logseq/logseq
[3]: https://github.com/tonsky/datascript
[4]: http://www.learndatalogtoday.org
