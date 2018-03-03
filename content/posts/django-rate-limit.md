---
title: "Django rate limit (and monkey patching)"
date: 2018-03-03T10:08:15+07:00
tags: ["django"]
draft: false
---

[Django Ratelimit][1] is a good rate limiter for Django. It has a convenient
decorator for views, so we can do this:

```python
@ratelimit(key='post:username', rate='5/m')
def login(request):
    return HttpResponse()
```

to limit the times we can try to login with one specific username to
5 requests per minute.

The decorator can be used with function-based views and class-based views, but
if we want to use it with built-in views, e.g. admin login view, we have to
monkey patch them.

Django allows us to patch any function from any module when init app.
I usually do this in `AppConfig` class, like this:

```python
class MyAppConfig(AppConfig):
    name = 'my_app'

    def ready(self):
        from my_app.monkey_patching import patch
        patch()
```

And this is the `patch()` function, for admin login view:

```python
def patch():
    from django.contrib.admin.sites import AdminSite
    AdminSite.login = new_login
```

Where `new_login()` is our patched function and `login()` is original function
that handles requests for logging user in.

The thing is we don't want to rewrite `new_login()` to be exactly like the old
`login()` function with the `ratelimit` decorator. We only want to "magically"
attach the decorator to the original function. How can we do that?

One idea is to write a function to input function `login()` and return function
`new_login()` with `ratelimit` decorator, like this:

```python
def limit_login(login):

    @ratelimit(key='post:username', rate='10/m', method='POST', block=True)
    def new_login(*args, **kwargs):
        return login(*args, **kwargs)

    return new_login
```

So now we can do this:

```python
def patch():
    from django.contrib.admin.sites import AdminSite
    AdminSite.login = limit_login(AdminSite.login)
```

We can make `limit_login()` function even more generic, with some defaults:


```python
def limit_rate(func, group=None, key='post:username', rate='10/m', method='POST', block=True):

    @ratelimit(group=group, key=key, rate=rate, method=method, block=block)
    def new_func(*args, **kwargs):
        return func(*args, **kwargs)

    return new_func
```

Now we can patch any view easily with our short `limit_rate()` function.

Have good time limiting around!


[1]: https://github.com/jsocol/django-ratelimit
