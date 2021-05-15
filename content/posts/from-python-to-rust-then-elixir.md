---
title: "From Python to Rust, then Elixir"
date: 2021-05-15T09:42:52+07:00
tags: ["python", "rust", "elixir", "wasm"]
draft: false
---

Recently I made [an app][0] to prepare for some kind of test I have to take.
I would have use [Anki][1] for this purpose but I don't want to spend too much
time learing how to make an Anki package again. Instead, I spent much more
time to create a new alternative, but at least I've learned some things new.


## 1. Porting Anki's SuperMemo2 from Python to Rust

I'm not confident enough to launch my own spaced repetition algorithm yet so
I decided to use [SuperMemo2][2] in a version implemented by Anki desktop app.
The Python code is on [one scheduler][3] file and [one test][4] file.

First thing first, we define an interface which is the core of the algorithm:

```rust
pub trait Sched {
    fn next_interval(&self, card: &Card, choice: Choice) -> i64;
    fn answer_card(&self, card: &mut Card, choice: Choice);
}
```

`Card` contains SuperMemo2's parameters such as queue name, due time, lapses.
`Choice` is an enum correspond to the answer we make, from **Forgot** to **Easy**.

`next_interval` shows estimated time to recall the card if we make a choice,
`answer_card` is the real action when we make that choice.

The next following steps are to translate Python functions to Rust methods one by
one. It is quite a smooth process, I feel like I am just adding type annotations
to Python code instead of writing new Rust code. The result is [a new Rust][5]
file, look quite the same as the old Python one.


## 2. Expose Rust API to Elixir Phoenix app

After having myself a spaced repetition package, I need to bring it to life.
To tell the truth, I chose Rust to port to because I know I can import it from
almost anywhere through [Foreign Function Interface][6] (FFI).

For no [specific reasons][7], let's make an Elixir app!

We use [Rustler][8] to build the bridge between Rust code and Erlang NIFs. The
setup is quite simple. After some times, we get a new Elixir module with the
APIs we need:

```
defmodule Memoet.SRS.Sm2 do
  @moduledoc """
  Sm2 API, calling Rust code
  When your NIF is loaded, it will override those functions below.
  """

  use Rustler, otp_app: :memoet, crate: "sm2"
  alias Memoet.SRS.{Config, Scheduler, Card, Choices}

  @spec new(Config.t(), integer(), integer()) :: Scheduler.t()
  def new(_config, _day_cut_off, _day_today), do: error()

  @spec next_interval(Card.t(), Scheduler.t(), Choices.t()) :: integer()
  def next_interval(_card, _scheduler, _choice), do: error()

  @spec answer_card(Card.t(), Scheduler.t(), Choices.t()) :: Card.t()
  def answer_card(_card, _scheduler, _choice), do: error()
end
```

Another way would work is to compile Rust code to Wasm, and then import it from
anywhere support Wasm runtime.

## 3. Summary

Rust is reducing the gap between languages. Maintaining the core logic in Rust
if possible should be considered as a wise choice.


[0]: https://github.com/memoetapp/memoet
[1]: https://apps.ankiweb.net/
[2]: https://www.supermemo.com/archives1990-2015/english/ol/sm2
[3]: https://github.com/ankitects/anki/blob/6e954e82a5/pylib/anki/scheduler/v2.py
[4]: https://github.com/ankitects/anki/blob/6e954e82a5/pylib/tests/test_schedv2.py
[5]: https://github.com/memoetapp/memoet/blob/master/native/sm2/src/srs/scheduler.rs
[6]: https://doc.rust-lang.org/1.2.0/book/rust-inside-other-languages.html
[7]: https://www.erlang-solutions.com/blog/why-elixir-is-the-programming-language-you-should-learn-in-2020/
[8]: https://github.com/rusterlium/rustler
