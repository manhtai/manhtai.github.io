---
title: "S3 Setup for Serving Public Content"
date: 2023-01-13T22:49:31+07:00
tags: ["AWS", "S3"]
draft: true
---

## IAM policy

Create a specific IAM user to interact with S3 bucket, and Cloudfront if you
use a CDN:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::assets.example.com/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudfront:CreateInvalidation"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

## Bucket policy

You should allow public objects, ACLs, and add a get public object policy for
the bucket:


```json
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::assets.example.com/*"
        }
    ]
}
```

## Bucket CORS

Allow CORS if you intend to use your assets cross domains:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "PUT",
            "HEAD",
            "POST",
            "DELETE"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [
            "ETag"
        ],
        "MaxAgeSeconds": 3000
    }
]
```
