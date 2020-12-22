---
title: "Flux<Databuffer> to InputStream"
date: 2020-04-11T10:08:00+07:00
tags: ["spring", "databuffer", "flux", "inputstream"]
draft: false
---

How can we convert a `Flux<DataBuffer>`, say, in a Spring's `FilePart.content()`
when uploading data, into a `InputStream` for consuming?

By using pipes!


```java
InputStream getInputStreamFromFluxDataBuffer(Flux<DataBuffer> data) throws IOException {
    PipedOutputStream osPipe = new PipedOutputStream();
    PipedInputStream isPipe = new PipedInputStream(osPipe);

    DataBufferUtils.write(data, osPipe)
            .subscribeOn(Schedulers.elastic())
            .doOnComplete(() -> {
                try {
                    osPipe.close();
                } catch (IOException ignored) {
                }
            })
            .subscribe(DataBufferUtils.releaseConsumer());
    return isPipe;
}
```

The code is quite trivial, but some notes worth mentioning here:

- 1, We need to subscribe on another Thread by using `Schedulers.elastic()` to
avoid blocking.

- 2, We need to close the `PipedOutputStream` when we finished, so downstream
subscriber will know when to stop.

- 3, `DataBufferUtils.write()` start writing as soon as the Flux from output
stream is subscribed to, so we use `DataBufferUtils.releaseConsumer()` to
start the writing immediately.
