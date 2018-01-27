---
title: "Django transaction"
date: 2018-01-27T17:39:26+07:00
draft: false
---

Django [documentation][1] about transaction points out:

> Django uses transactions or savepoints automatically to guarantee the integrity
> of ORM operations that require multiple queries, especially `delete()` and
>`update()` queries.

This means whenever we call `save()` or `create()`, it's already wrapped in
a transaction. And usually new data is not in the database yet when we try to
get that again somewhere after.

To make sure it's commited, we have to use `transaction.on_commit()`.

There are 2 popular cases I find that we must use `on_commit()` function.

*The first one* is when we send task to a Celery queue. The error we usually made
here is to put that on a `post_save` signal and hope for the best. Remember that
`post_save` is in the same transaction with `save()`, so there is no guarantee
that new data will be in the database when Celery task get it from there.

We must use put the task to `on_commit()` function like this:


```python
transaction.on_commit(lambda: celery_task_with_id(id))
```


*The second case* is when we want to do something after all inline forms in
admin page is saved. But the thing we actually want is data is commited to
database. You already know how to do it, just like the case above.

The catch here is we can put `on_commit()` function in many places, as long as
it's in the transaction. I usually put that on `save_model()` or `save_related()`,
depend on what extra infomation I need for further processing.



[1]: https://docs.djangoproject.com/en/dev/topics/db/transactions/
