# gophspit
A tool for translating from a subset of the Gopher protocol to HTML.

## Dependencies
You need to have GNU Guile 2.0 with regular expression support installed.  I have not tested this script with Guile 1.8.

## Usage

    cat my-gopher-site.goph | ./gophspit.scm > my-gopher-site.html

## Special Features
Because this tool outputs to HTML, it is desirable to be able to specify relative paths.  If, for example, you don't have a domain name or don't care which domain name someone uses to connect to your site, then you can use the following address and port fields:

* Address = (ROOT), Port = (ROOT):  This makes the generated page interpret the selector field as an absolute path from the root of your domain (i.e., no extra domain info is added to the selector).
* Address = (HERE), Port = (HERE):  This makes the generated page interpret the selector field as a relative path (i.e., a "." is prepended and no extra domain info is added).

## License
gophspit is licensed under the CC0 1.0 Universal license, a copy of which should have come with this package.
To the extent possible under law, I waive all copyright and related or neighboring rights to gophspit. I make no warranty about the work and disclaim liability for all uses of the work, to the extent possible under law.
