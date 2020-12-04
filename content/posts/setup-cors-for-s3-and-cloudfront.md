---
title: "Setup CORS for S3 and Cloudfront"
date: 2020-12-04T20:53:21+07:00
tags: ['s3', 'cloudfront', 'aws']
draft: false
---

CORS problem arises in one of our apps because static files return from
CloudFront do not allow CORS. Specifically, they do not return following
header:

```markdown
Access-Control-Allow-Origin: *
```

The problem is, we've setup CloudFront and S3 to support CORS as mentioned in
[the docs][0].

In S3 bucket rules, we have:


```json
[
    {
        "AllowedHeaders": [
            "Authorization"
        ],
        "AllowedMethods": [
            "GET"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 20000
    }
]
```

In CloudFront, we have:

```markdown
Cache and origin request settings: Use a cache policy and origin request policy
Cache Policy                     : Managed-CachingOptimized
Origin Request Policy            : Managed-CORS-S3Origin
```

All looks good, but our problem persists.

Continue following [the docs][0]:


> How does Amazon S3 evaluate the CORS configuration on a bucket?

> When Amazon S3 receives a preflight request from a browser, it evaluates the
> CORS configuration for the bucket and uses the first CORSRule rule that matches
> the incoming browser request to enable a cross-origin request. For a rule to
> match, the following conditions must be met:

>    The request's Origin header must match an AllowedOrigin element.

>    The request method (for example, GET or PUT) or the Access-Control-Request-Method
>    header in case of a preflight OPTIONS request must be one of the AllowedMethod elements.

>    Every header listed in the request's Access-Control-Request-Headers header on the
>    preflight request must match an AllowedHeader element.


We inspect the GET request that the browser makes to get the static files and
observe that the request header does not include `Origin` in the first request
send to CloudFront, and CloudFront does not send back
`Access-Control-Allow-Origin` header.

After the first request, CloudFront will cache the response header, and even
if the browser send the `Origin` request header next time, it still does not send back
`Access-Control-Allow-Origin` response header.

The solution is quite simple than we thought, we create a new cache policy with
`Origin` be one of the cache keys (the only different one from `Managed-CachingOptimized`
policy), then the problem goes away.

This works fine if the origin number is small as in our case.

There are two other ways:

- (1) Use Lambda@Edge to set the necessary header.

- (2) Override origin header from CloudFront to a dummy one.


(2) feels a little bit hacky but it might be the best solution.


[0]: https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html
