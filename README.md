bit view
========
A tool to quickly examine the general structure of a file. Inspired by [baudline's bit view](http://www.baudline.com/manual/open_file.html#bit_view). Also uses [ent](http://www.fourmilab.ch/random/).

![File manager context menu](http://www.cs.helsinki.fi/u/okraisan/bitview-menu.png)

Features
--------

![Screenshot](http://www.cs.helsinki.fi/u/okraisan/bitshot-readme.png)

1. hexdump. Enough said.
2. Tries to determine file type based on magic numbers etc (actually the output of the file command).
3. Some indicators that help determine whether the data is truly random (actually parsed output of the ent command). The more to the right a needle is, the more random the data. Entropy and mean are self-explanatory. Corr shows serial correlation. Chi^2 calculates a chi-squared test on the data, something that is very sensitive to any kind of non-random patterns even in pseudorandom number generators.
4. Byte value histogram, 0..255.
5. Poincaré plot of all byte values. A Poincaré plot plots byte x against byte (x+1). This produces quite recognizable patterns for many kinds of (non-random) data formats.

Licensing
---------

    Copyright (c) 2012, windytan (Oona Räisänen)
    
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
