---
title: "Django staticfiles"
date: 2018-01-30T22:31:54+07:00
tags: ["django"]
draft: false
---

Recently we move our sass & js complier from good ol' [django-compressor][1]
and [django-require][4] (one for compile sass, one for bundle js), to
[webpack][2], a client-side bundler (it will do both sass & js for us). It's
a long process, I admit, but things go smoothly eventually. Till something
pops up.

Before, we use django-require's `OptimizedStaticFilesStorage` to generate
bundlers offline. This storage will generate a cache buster files side by
side with original staticfiles in our `STATIC_ROOT` folder. Some folder will
look like this after collectstatic:

```sh
# public/

cms/header.css
cms/header.0847d6eff302.css
```

After that, we must use [aws cli][5] to sync staticfiles manually to our S3
bucket, then set `STATIC_URL` to our Cloudfront endpoint. It works, till now.

I now remove both django-compressor and django-require, and use Django's
`ManifestFilesMixin` storage instead, with combination with `S3BotoStorage`.

We must change default `manifest_name` a little bit using git commit digest
to support multiple deployments in the same bucket. The storage we use now
looks like this:

```python
class S3ManifestStaticFilesStorage(ManifestFilesMixin, S3BotoStorage):
    """
    This storage uses S3 as backend and having cache busting property of
    ManifestStaticFilesStorage
    """
    manifest_strict = False

    @property
    def manifest_name(self):
        filename = 'staticfiles-{version}.json'
        version = subprocess.check_output(['git', 'rev-parse', 'HEAD']).strip()
        return filename.format(version=version.decode('utf-8'))
```

Now whenever we call `collectstatic`, it will collect all our staticfiles to
S3, no need another step to sync them manually.

Things will work beautifully if Django collect all files, instead it
**WILL NOT** collect anything which are collected before, even when we've
changed our storage backend.

I have done many twists back and forth but the `static` template tags got wrong
urls all the time. Then after checking `last-modified` in one of response
header, I find out that the file hasn't change for very long time. Hence
Django mustn't touch these files when I change staticfiles backend storage.

Voyla!

Just copy all staticfiles form old folder into the new one, and problem
solved, new files would work as expected.


[1]: https://django-compressor.readthedocs.io/en/latest/
[2]: https://webpack.js.org/
[3]: https://django-compressor.readthedocs.io/en/latest/scenarios/#offline-compression
[4]: https://github.com/etianen/django-require/
[5]: https://aws.amazon.com/cli/
