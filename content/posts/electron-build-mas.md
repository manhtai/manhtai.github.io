---
title: "Electron Build for Mac App Store"
date: 2023-01-15T16:03:00+07:00
tags: ["Electron", "MAS"]
draft: false
---

There are 2 ways to publish a macOS Electron app: on the Mac App Store and outside of it.
And they need different configurations to build successfully.


## Outside of App Store

The [docs][1] for packaging macOS app to be installed outside Mac App Store is pretty clear.
All you need are:

1. Build with a hardened runtime
2. Sign with a valid developer ID
3. Notarize your app

### Hardened runtime

You need to set `"hardenedRuntime": true` in your build config, along with a `mac.plist`
file with these entitlements:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
  </dict>
</plist>
```

The complete build config for "mac" should be:

```json
"mac": {
  "hardenedRuntime" : true,
  "gatekeeperAssess": false,
  "entitlements": "build/entitlements.mac.plist",
  "entitlementsInherit": "build/entitlements.mac.plist"
}
```

### Sign

You can use a free development account ID to sign the app. But for notarizing, you need
a paid developer account. It costs $99 per year.

### Notarize

To notarize the app, you need to create an app specific password on your iCloud account, and
then use `electron-notarize` after signing the app:

```json
"afterSign": "build/notarize.js",
```


```js
// build/notarize.js
const { notarize } = require('electron-notarize');
const { build } = require('../package.json');

exports.default = async function notarizeMacos(context) {
  const { electronPlatformName, appOutDir } = context;
  if (electronPlatformName !== 'darwin') {
    return;
  }

  const appName = context.packager.appInfo.productFilename;

  await notarize({
    appBundleId: build.appId,
    appPath: `${appOutDir}/${appName}.app`,
    appleId: process.env.APPLE_ID,
    appleIdPassword: process.env.APPLE_ID_PASS,
  });
};
```

## Through Mac App Store (MAS)

The [guide][2] for MAS submission should work, but it wasn't enough for me.
Anyway, for MAS, you need:

1. Build **without** a hardened runtime and **without** notarizing
2. Sign with a distribution key, a provision profile and proper entitlements
3. Upload to App Center using Transporter app and test your app before submitting using TestFlight

For #1, just disable the corresponding configurations.

### Sign

#### Distribution certificates

You will need a pair of "3rd Party Mac Developer Installer" and "Apple Distribution"
keys. Create new certificates from XCode then select and export both of them from
Keychain Access into a `.p12` key should do the work.

#### Provision profile

This profile is created and downloaded from the App Developer account. You need to create
an App ID for submission and a distribution certificate before creating a profile to attach
to it.

#### Entitlements

MAS app requireds [App Sandbox][3], so you need 2 entitlements, 1 `mas.plist` with sandbox
enabled and 1 `mas.inherit.plist`, same as `.mas.plist` but for frameworks and bundles.

- `entitlements.mas.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
  </dict>
</plist>
```

- `entitlements.mas.inherit.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.inherit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
  </dict>
</plist>
```


The final build configuration for #1 and #2 steps should be: 


```json
{
    ...
    "afterSign": "DoNothing.js",
    "mac": {
      "target": [
        "mas"
      ],
      "type": "distribution",
      "gatekeeperAssess": false
    },
    "mas": {
      "entitlements": "entitlements.mas.plist",
      "entitlementsInherit": "entitlements.mas.inherit.plist",
      "provisioningProfile": "embedded.provisionprofile",
      "hardenedRuntime": false
    }
    ...
}
```


### Upload and Test

After building into a `.pkg` files, verify and then upload the app into App Center. Because you can't
open the `.pkg` app in your local machine, you need TestFlight to do that. Make sure the app work as
expected before submitting for review.

Oh and the app I submitted to Mac App Store is [PDF Mail Merger][0].


[0]: https://pdfmailmerger.github.io/
[1]: https://www.electron.build/code-signing
[2]: https://www.electronjs.org/docs/latest/tutorial/mac-app-store-submission-guide
[3]: https://developer.apple.com/documentation/security/app_sandbox
