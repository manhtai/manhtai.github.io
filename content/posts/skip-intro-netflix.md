---
title: "Auto Skip Intro on Netflix"
date: 2022-10-10T14:31:15+07:00
tags: ["userscripts"]
draft: false
---

I have read about [userscript][0] before, but never found the needs for it.
Until recently I watch too much anime on Netflix and hate to skip intro
every 20 minutes. Oh and I like to watch on Safari these day.


## First attempt: Safari extensions

Someone must think about this and already make an extension for me. And I
tried multiple apps, both paid and free apps from mac Appstore, nothing
works.

Why is that? Should the job be simple as check for the "Skip Intro" text and
click the button for me? I feel disappointed by not finding any extentions
that works properly on this simple matter.


## Second attemp: userscripts

I have to write the extension myself then. But how? Turn out some guys on the
net develop an open-source [extension][1] to manage user scripts. And we can
run whatever pieces of code we like on whatever web pages we want. And it's
even free!

Here is my code for skipping intro on Netflix. Feel free to paste this onto
your userscripts editor.


```js
// ==UserScript==
// @name         Netflix Auto-Skip Intro
// @match        https://www.netflix.com/*
// ==/UserScript==

(function() {
    'use strict';

    setInterval(() => {
        const skip = document.querySelector('.watch-video--skip-content-button');
        if (skip){
            skip.click();
        }
    }, 500);
})();
```

A catch here is the class name `.watch-video--skip-content-button` may change
from time to time. So when it doesn't work anymore, inspect the "Skip Intro"
button and update the script yourself.


## Other browsers

Firefox, Chrome and other browsers have its own userscript manager extensions:
[Tampermonkey][2], [Greasemonkey][3], etc. Use the one you like.


[0]: https://en.wikipedia.org/wiki/Userscript
[1]: https://github.com/quoid/userscripts
[2]: https://www.tampermonkey.net/
[3]: https://www.greasespot.net/
