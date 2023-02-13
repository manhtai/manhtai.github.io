---
title: "Set NS Record for Cloudflare Domains"
date: 2023-02-13T20:51:06+07:00
tags: ["Cloudflare", "domain"]
draft: false
---

You can't set your NS record for your root domain on Cloudflare dashboard, surprise!

We have to use the [Cloudflare API][1] for that. What a hassle!

First thing first, you need an API token. Go to your [profile][2] on the
dashboard to get it. The key we need is under Global API key label.


Next, list out all your Cloudflare accounts, ideally this API return 1:


```sh
curl -X GET "https://api.cloudflare.com/client/v4/accounts?page=1&per_page=20" \
     -H "X-Auth-Email: user@example.com" \
     -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
     -H "Content-Type: application/json"
```

Then, change the NS:


```sh
curl -X PUT "https://api.cloudflare.com/client/v4/accounts/your_account_id/registrar/domains/your_domain.com" \
     -H "X-Auth-Email: user@example.com" \
     -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
     -H "Content-Type: application/json" \
     --data '{"name_servers":["your1.ns.wtf.com","your2.ns.wtf.com"]}'
```


Keep up the good work Cloudflare! Very creative and user friendly, we love it!


[1]: https://api.cloudflare.com
[2]: https://dash.cloudflare.com/profile/api-tokens
