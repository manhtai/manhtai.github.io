---
title: "How to print Unicode text to a Thermal printer using React Native"
date: 2018-06-23T21:17:15+07:00
tags: ["thermal printer", "react native"]
commentid: 2
draft: false
---

In previous [post][1] about using React Native to build our own ERP app, I've
mentioned about printing Vietnamese characters to a [thermal printer][2], in
this post I will show you how to do it.

Although this post is about printing Vietnamese using React Native, you must
keep in mind that it is not only apply to Vietnamese and React Native, but
for any _native_ mobile framework to print Unicode characters to a thermal
printer. Just make sure your language is supported in thermal printer [code
page][5].

Firstly, you must get a library to print arbitrary characters to a thermal
printer. We used [react-native-bluetooth-serial][3] for our ERP app.

It's API for printing out a message as simple as this:

```javascript
BluetoothSerial.write(Buffer|String data)
```

Secondly, you must know that a thermal printer will support some kind of
ESC/POS commands for parameterizing printed characters, like changing
font family, font size, barcode printing, etc. Depending on what thermal
printer manufacturer you are using, it will have some groups of commands that
we can use, for example, we can find ECS/POS reference about Epson printer
[here][4].

So all we need to print out Vietnamese characters is to send out some
commands to set up the printer for using Vietnamese font and [code page][5]!

Our thermal printer does support only TCVN3 code page, so we must encode our
Unicode message to TCVN3, and then just print it out, like this:

```javascript
// We use iconv to convert Unicode message to TCVN3
const TCVN3message = iconv.encode(message, 'tcvn');

// [0x1b, 0x74, 48] is POS command for set up TCVN3 code page
const TCVN3codepage = new Buffer([0x1b, 0x74, 48]);

// Push write command to Promise array
const writePromises = [];
writePromises.push(BluetoothSerial.write(TCVN3codepage));
writePromises.push(BluetoothSerial.write(TCVN3message));

// Print out messages
Promise.all(writePromises);
```

That's it!

Using ESC/POS commands, we can customize our printing format even more, like
font size, font weight, etc. Another longer ESC/POS reference can be found
[here][6].

A minor thing to note is that some printer will not default to character font
A for us, so the text might get too little or too large. You can use a command
to set it to character font A, like this:


```javascript
const characterFontA = new Buffer([0x1b, 0x21, 0]);
```

Have fun printing things out!


[1]: /posts/building-erp-using-django-react-native
[2]: https://en.wikipedia.org/wiki/Thermal_printing
[3]: https://github.com/rusel1989/react-native-bluetooth-serial
[4]: http://content.epson.de/fileadmin/content/files/RSD/downloads/escpos.pdf
[5]: https://en.wikipedia.org/wiki/Code_page
[6]: http://www.aures-support.fr/DATA/utility/Commande%20ESCPOS.pdf
