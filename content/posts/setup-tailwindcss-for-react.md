---
title: "Setup TailwindCSS for React"
date: 2020-11-01T15:10:07+07:00
tags: ['tailwindcss', 'react']
draft: false
---

## 1. Basic setup

After installing TailwindCSS and doing [the basic setup][0], you need
PostCSS-CLI to build out `main.css`, setup some commands in `package.json`
to do that:

```
{
  "scripts": {
    "start": "npm run watch:css && react-scripts start",
    "build": "npm run build:css && react-scripts build",
    "deploy": "NODE_ENV=production npm run build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "watch:css": "postcss src/css/tailwind.css -o src/css/main.css",
    "build:css": "postcss src/css/tailwind.css -o src/css/main.css"
  }
}
```

Don't forget to import `main.css` in your React index file:


```
import './css/main.css';
```


## 2. Install font family


Choose your favorite font from a `fontsouce-*` package and extend Tailwind
config, I choose 'Nunito':

```
theme: {
  extend: {
    fontFamily: {
      sans: ["Nunito", ...defaultTheme.fontFamily.sans]
    }
  },
},
```

Remember to include the font in your index file, too:


```
import 'fontsource-nunito';
```

## 3. Set default color

If you don't want black as your default text body color, override it in
plugins config, I choose `blue-900` as my default color, so:

```
  plugins: [
    plugin(function({ addBase, config }) {
      addBase({
        'body': { color: config('theme.colors.blue.900') },
      })
    })
  ],
```

## 4. Purge unused CSS

Full size of TailwindCSS is around 2MB, but you rarely use it all, TailwindCSS
[official guide][1] recommends not to use string concatenation to create class
names, but if you still want to do that, use whitelist patterns to bypass the
cleaning.

For example if I want to keep all colors for background and text:

```
  purge: {
    content: [
      "./src/**/*.{ts,tsx,html}",
    ],
    options: {
      whitelistPatterns: [/^bg-/, /^text-/],
    },
  },
```

You can find my full setup for my [new React app][3] in [Github][2].



[0]: https://tailwindcss.com/docs/installation
[1]: https://tailwindcss.com/docs/controlling-file-size
[2]: https://github.com/manhtai/metaboard
[3]: https://metaboard.net
