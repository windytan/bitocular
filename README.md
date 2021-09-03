bitocular
========
A tool to quickly examine the general structure of a file. Inspired by [baudline's bit view](http://www.baudline.com/manual/open_file.html#bit_view). Also uses [ent](http://www.fourmilab.ch/random/).

![File manager context menu](http://www.cs.helsinki.fi/u/okraisan/bitview-menu.png)

***This project is not maintained any more.***

Features
--------

![Screenshot](http://www.cs.helsinki.fi/u/okraisan/bitshot-readme.png)

(1) hexdump: A hex dump.

(2) magic: Tries to determine file type based on magic numbers etc (actually the output of the `file` command)

(3) randomness: Some indicators that help determine if the data is truly random (actually parsed output of the `ent` command). The graphic gauges are designed so that for more random data the needles are more to the right.

*  entropy: self-explanatory.
*  mean: arithmetic mean value of all bytes.
*  corr: serial correlation coefficient.
*  chi²: chi-square test, very sensitive to non-randomness even in pseudorandom number generators. Displayed is a percentage of how frequently a truly random sequence would exceed the test result.

(4) histogram: Byte value histogram, 0x00 .. 0xff.

(5) poincare: The Poincaré plot is a plot of all bytes x(n) againts x(n+1). This produces quite recognizable patterns for many kinds of (non-random) data formats.

Licensing
---------

    Copyright (c) 2012-2013, windytan (Oona Räisänen)
    
    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.
    
    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
