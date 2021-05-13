---
title: "NodeJS worker patterns"
date: 2021-05-13T19:45:08+07:00
tags: ["nodejs", "worker"]
draft: false
---


Sometimes we just need to run a separated worker to process long running jobs in
NodeJS, what are our options?

First step is to put the heavy actions into a queue. The second step is to run
a poller to pull out the messages and execute theme one by one.

What can we do to max out those worker performance?


### 1, Fork a child process

NodeJS [supports][0] spinning off a new child process from the main one.
It's too expensive so we shouldn't use it. It sure has uses on its own though.


### 2, Fire up Worker threads

From Node 10, `worker_threads` is [supported][1], the code is trivial enough:

```
const {
  Worker, isMainThread, parentPort, workerData
} = require('worker_threads');

if (isMainThread) {
  module.exports = function parseJSAsync(script) {
    return new Promise((resolve, reject) => {
      const worker = new Worker(__filename, {
        workerData: script
      });
      worker.on('message', resolve);
      worker.on('error', reject);
      worker.on('exit', (code) => {
        if (code !== 0)
          reject(new Error(`Worker stopped with exit code ${code}`));
      });
    });
  };
} else {
  const { parse } = require('some-js-parsing-library');
  const script = workerData;
  parentPort.postMessage(parse(script));
}
```

These workers are useful for performing CPU-intensive tasks, not much effects
for IO operations.


### 3, EventEmitter

Who would have thought about [that][2]?


```
const EventEmitter = require('events');

const myWorker = new EventEmitter();

myWorker.on('poll', () => {
  console.log('Go and do work');

  myWorker.emit('poll');
});


myWorker.emit('poll');
```

We could fire up as many `EventEmitter` as we want and keep them doing the
work for us.


[0]: https://nodejs.org/api/child_process.html
[1]: https://nodejs.org/api/worker_threads.html
[2]: https://nodejs.org/api/events.html
