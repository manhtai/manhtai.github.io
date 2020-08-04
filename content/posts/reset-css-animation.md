---
title: "Reset Css Animation"
date: 2020-08-04T16:46:11+07:00
tags: ["css"]
draft: false
---

There is no easy way to reset CSS animation when it starts playing, we have at
least 2 "hacky" ways though.

- 1, Nested `requestAnimationFrame()`:

This is the tip from [Mozilla][1], use a nested `requestAnimationFrame()` to
trigger re-render animation

```
function play() {
  document.querySelector(".box").className = "box";
  window.requestAnimationFrame(function(time) {
    window.requestAnimationFrame(function(time) {
      document.querySelector(".box").className = "box changing";
    });
  });
}
```

- 2, Trigger reflow using Element APIs et al:

```
var el = document.querySelector(".box")
el.className = "box";
el.focus() // Or el.offsetLeft, el.offsetRight, etc
el.className = "box changing";
```

Have fun with CSS animation!




[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Animations/Tips
