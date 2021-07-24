---
title: "Electron with React: How to open a native dialog"
date: 2021-07-24T11:00:04+07:00
tags: ["electron", "react"]
draft: false
---

Recently I'm building a desktop app for developers who is working with
plain text: [PlainBelt][0]. It uses Electron with React [boilerplate][1]
(ERB), and the old mighty **remote** module [won't work][2] anymore.

So how can we open a native dialog without the **remote** module?


### Register event handler on the Main process

In ERB, the Main filename happens to be `main.dev.ts`:

```typescript
ipcMain.handle(
  'open-file',
  async (_event: IpcMainInvokeEvent, filters: FileFilter[]) => {
    const files = await dialog.showOpenDialog({
      properties: ['openFile'],
      filters,
    });

    let content = '';
    if (files) {
      const buffer = await promisify(fs.readFile)(files.filePaths[0]);
      content = buffer.toString();
    }
    return content;
  }
);
```

This function will open a native dialog with options that you define on
`filters` and return an object that contains a list of file paths.
We just read the first file content and return it to the renderer.


### Invoke from Renderer process


From a React component, we can invoke the registered handler in Main:

```typescript
  const [content, setContent] = useState()

  const handleOpen = async () => {
    const filters = [{ name: 'Text Files', extensions: ['txt'] }];
    const content = await ipcRenderer.invoke('open-file', filters);
    setContent(content);
  };
```

We get the content back, now do whatever you want with it!


[0]: https://github.com/plainbelt/plainbelt
[1]: https://github.com/electron-react-boilerplate/electron-react-boilerplate
[2]: https://github.com/electron/electron/issues/21408
