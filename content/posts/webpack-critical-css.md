---
title: "Webpack critical CSS plugin"
date: 2018-02-01T19:17:48+07:00
draft: false
---

If you don't already know what critical CSS is, then do [get some insights][5]
for your web, read the reference about [optimizing CSS delivery][6], and I'll
meet you here after. Really, just do it.

We use Django for some of our web projects for the server side. And with
support from [django-webpack-loader][1], now we can use Webpack in the client
side, using massive libraries from Nodejs world to power our frontend part.
We feel very happy about this integration.

And now I have to find a library support generate critical CSS from our CSS
bundler, and put only that to `<head>`, not all our CSS build.

[Some][2] [of][3] [them][4] do exists. But it may do more work than I want:
modify HTML / exact CSS file out of Webpack build process, or it is just
a library that can output a critical CSS file. Yeah, time for me to write the
plugin I want myself.

So what do I want?

> I want a plugin that can get the CSS output from latest Webpack build step, do
> some magic to get critical CSS from that, then output an additional CSS file
> for me, then I'll decide what to do with it later.

You can do exactly that with a plugin that wrap around a serious critical CSS
extractor. I choose [penthouse][8] to do the heavy work, follow the [guide][7]
on how to write a Webpack plugin, I create [webpack-critical-css-plugin][0]
for you to use.

Take a look, and send some PRs!

Now for it to work with **django-webpack-loader**, put your second CSS build
(the critical CSS) in the head, and put the first one (the original CSS) in
the body.

Try it, then re-check your web score in Google PageSpeed Insights!


[0]: https://github.com/manhtai/webpack-critical-css-plugin
[1]: https://github.com/ezhome/django-webpack-loader
[2]: https://github.com/addyosmani/critical
[3]: https://github.com/anthonygore/html-critical-webpack-plugin
[4]: https://github.com/pocketjoso/penthouse
[5]: https://developers.google.com/speed/pagespeed/insights/
[6]: https://developers.google.com/speed/docs/insights/OptimizeCSSDelivery
[7]: https://github.com/webpack/docs/wiki/how-to-write-a-plugin
[8]: https://github.com/pocketjoso/penthouse
