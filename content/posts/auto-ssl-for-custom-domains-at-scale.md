---
title: "Auto SSL for custom domains at scale"
date: 2022-01-10T21:07:10+07:00
tags: ["Go", "SSL"]
draft: false
---

Up to some scale, your [SaaS][1] will have to support white-label
customers with their custom domains. And enabling [SSL][2] (TLS now
actually) for them is a must. How to automate this process and
support a large number of custom domains at scale? Behold for
Caddy will come and save your day!


## 1. What is Caddy?


[Caddy][0] is an open-source web server with automatic HTTPS written in Go.
Besides automatic HTTPS, it can also do HTTPS on demand and scale
horizontally when using a shared storage system for certificates. Popular
choices are Redis, Consul, S3 or DynamoDB.


## 2. How do Caddy work?


Our request flow will look like this:

Client (browsers) => Caddy server (auto & on-demand SSL) => Your proxy server (forward requests based on custom domains) => Your target server (do the real work)


Simple enough, eh? On localhost, Caddyfile looks like this:

```
https://

tls internal {
	on_demand
}

reverse_proxy 127.0.0.1:8080
```

Our proxy server looks like this:

```go
package main

import (
	"net/http"
	"net/http/httputil"
	"net/url"
)

func main() {
	remotes := map[string]string{
		"localhost":          "https://www.google.com",
	}

	handler := func(w http.ResponseWriter, r *http.Request) {
		rawURL := remotes[r.Host]
		remote, err := url.Parse(rawURL)
		if err != nil {
			panic(err)
		}

		w.Header().Set("User-Custom-Domain", r.Host)
		r.Host = remote.Host

		proxy := httputil.NewSingleHostReverseProxy(remote)
		proxy.ServeHTTP(w, r)
	}

	http.HandleFunc("/", handler)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

```

The target server here is google.com.

Now when you visit https://localhost, it will show google.com website. Google
just got another custom domain from us with SSL!



[0]: https://caddyserver.com/
[1]: https://en.wikipedia.org/wiki/Software_as_a_service
[2]: https://en.wikipedia.org/wiki/Transport_Layer_Security
