---
title: "Fast GIF generation in Go"
date: 2023-11-03T20:38:51+07:00
tags: ["Go", "GIF"]
draft: false
---

Go has a built-in GIF [package][0]. This works fine for encoding static images into a GIF image. The
slow problem resides in another [package][1] that we use to prepare those static images. But let's talk
about the `gif` package first.

The `EncodeAll(w io.Writer, g *GIF) error` function converts a `*GIF` struct, which contains an array of
`*image.Paletted` into GIF format, and then writes into `io.Writer`. `image.Paletted` is an in-memory image of
uint8 indices into a given palette.

We must use a paletted image here instead of a "normal" image because GIF files can hold up to 256 colors,
whatever it is, that's called a palette. So to make a GIF, we need to choose a color palette beforehand, up
to 256 colors, and then convert all the needed images into that color space. With the hex format, we have at
least 16 million colors, we have to map those 16M colors into 256 colors of our GIF. And we need the `draw`
package for that.

`Draw(dst Image, r image.Rectangle, src image.Image, sp image.Point, op Op)` will replace the rectangle `r`
of destination image `dst` by the source image `src`, align by point `sp`. We're on the paletted image case
so the `dst` image will be a paletted one. `Draw` will call `DrawMask`, and then it will call `drawPaletted`.
`drawPaletted` will loop over each source pixel, finding the matching color for each pixel from the color
palette by minimizing the sum squared difference. The code looks like this:

```go
bestIndex, bestSum := 0, uint32(1<<32-1)
for index, p := range palette {
    sum := sqDiff(er, p[0]) + sqDiff(eg, p[1]) + sqDiff(eb, p[2]) + sqDiff(ea, p[3])
    if sum < bestSum {
        bestIndex, bestSum = index, sum
        if sum == 0 {
            break
        }
    }
}
```

The problem here is for each GIF frame, we have to loop over `palette` every time to find the matching colors.
If we use up 256 colors on the palette, then this loop will run 256 times for each pixel, which is slow. Solution?
A cache! Let's put that in. We use `sync.Map` here because of course we will generate GIF frames concurrently,
and the normal Go `map` is not thread-safe.

```
// Out of pixel loop
cache := sync.Map{}

// The use the cache
cachedKey := [4]int32{er, eg, eb, ea}
bi, ok := cached.Load(cachedKey)
if ok {
    bestIndex = bi.(int)
} else {
    for index, p := range palette {
        sum := sqDiff(er, p[0]) + sqDiff(eg, p[1]) + sqDiff(eb, p[2]) + sqDiff(ea, p[3])
        if sum < bestSum {
            bestIndex, bestSum = index, sum
            if sum == 0 {
                break
            }
        }
    }
    cached.Store(cachedKey, bestIndex)
}
```

And how do I know how to optimize this specific piece of code again? Well, inject this into your slow code:

```go
import "github.com/pkg/profile"

func main() {
    defer profile.Start().Stop()

    // Your slow code here
}
```

It will output something like `/var/folders/y0/9l417xks1_s9_hdpxh88lrwr0000gn/T/profile1238445006/cpu.pprof`, then
use your Go:

```shell
go tool pprof -web /var/folders/y0/9l417xks1_s9_hdpxh88lrwr0000gn/T/profile1238445006/cpu.pprof
```

That's it. I found the bottleneck using `pprof`, then I cloned the `draw` package, added a cache, and made the GIF
generator run fast. Now I enjoy my GIFs.

![](/gif.webp)

[0]: https://pkg.go.dev/image/gif
[1]: https://pkg.go.dev/image/draw
