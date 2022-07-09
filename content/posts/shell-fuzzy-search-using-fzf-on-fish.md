---
title: "Shell fuzzy search using fzf on Fish"
date: 2022-07-08T15:59:47+07:00
tags: ["shell", "fuzzy"]
draft: false
---

I mostly use an IDE for coding these days, but vim keybindings mode will be on
and the terminal window with a proper shell must always be opened.

I wouldn't want to code without CLI, and Fish shell with fzf fuzzy search
brought it up to another level. In combination with many fancy things that
are developed for the CLI recently, I feel very excited. Another reason to
believe that CLI will live on forever!

Now for my new setup with Fish and fzf.


1, [Fish][1] first

```sh
brew install fish
```

2, Then [fisher][2]

```sh
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
```

3, Then [fzf.fish][3]

```sh
fisher install PatrickF1/fzf.fish
```

4, And multiple [fancy][4] [small][5] [stuff][6]s

```sh
cargo install bat fd-find lsd
```

5, Then config some key bindings

Mine are:

- `Ctrl + T`: Search directories
- `Ctrl + K`: Search processes
- `Ctrl + R`: Search history (default)
- `Ctrl + V`: search variables (default)


```text
fzf_configure_bindings --directory=\ct --processes=\ck
```

Enjoy the magic of CLI!


[1]: https://github.com/fish-shell/fish-shell
[2]: https://github.com/jorgebucaran/fisher
[3]: https://github.com/PatrickF1/fzf.fish
[4]: https://github.com/sharkdp/bat
[5]: https://github.com/sharkdp/fd
[6]: https://github.com/Peltoche/lsd
