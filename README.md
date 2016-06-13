# gophspit
A tool for translating Gopher directories into HTML pages.

## Dependencies
You need to have GNU Guile 2.0 with regular expression support installed.  I have not tested this script with Guile 1.8.

## Usage

    $ cat my-gopher-site.goph | ./gophspit.scm > my-gopher-site.html

## URL links
By default, actual Gopher protocol links are generated using the hostname and port fields of lines.  If you want to generate other links, such as HTTP links, use URL: syntax in the selector field.  In that case, the hostname and port fields are ignored.  Example:

    hSome Coding Website	URL:github.com	(NULL)	0

## Tools
The plain2goph.scm script in the tools/ directory takes text from standard input and outputs an "info-line" version of it, with trailing whitespace removed.  This is useful if you have, for example, a paragraph or ascii art image that you want to include on the page.

    $ cat logo.txt | ./tools/plain2goph.scm > logo.goph

## License
gophspit is licensed under the CC0 1.0 Universal license, a copy of which should have come with this package.  To the extent possible under law, I waive all copyright and related or neighboring rights to gophspit. I make no warranty about the work and disclaim liability for all uses of the work, to the extent possible under law.
