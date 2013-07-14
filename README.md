Curriculum Vitae
================

Introduction
------------
This directory contains the source files for the LaTeX code for my Curriculum
Vitae (CV) and my cover letter. To compile the documents, execute the command
`make' from the root directory. The documents will be output to
`build/CurriculumVitae.pdf' and `build/CoverLetter.pdf'.

License
-------
Copyright &copy; 2013 Joshua Spence &lt;<josh@joshuaspence.com>&gt;

This work is free. You can redistribute it and/or modify it under the terms of
the [Do What The Fuck You Want To Public License][wtfpl], Version 2, as
published by [Sam Hocevar](mailto:sam@hocevar.net). See
[LICENSE.md](LICENSE.md) file for more details.

Dependencies
------------
To create the [Gmail][gmail] filters (in XML format), the following packages
are required:

* ruby (>= 1.9.2)
* bundler (>= 1.2.0)
* gmail-britta (>= 0.1.6)

These packages can be installed using the following commands:

    apt-get install ruby
    gem install bundler
    gem install gmail-britta

Instructions
------------
To generate the [Gmail][gmail] filters in XML format, just run:

    ruby filters.rb


[github]: <https://github.com/antifuchs/gmail-britta>
[gmail]: <https://mail.google.com>
[wtfpl]: <http://www.wtfpl.net>
