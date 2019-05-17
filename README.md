Scrape of TLUG List Archive Site
--------------------------------

This repo contains a top-level script, `Scrape`, which fetches all
(publicly available) files served by <https://lists.tlug.jp>, and the
scraped content, which is updated on an ad-hoc basis by whoever feels
like doing it.


Site Content
------------

All content fetched from the site is under `lists.tlug.jp/`.

- `ML/`: `tlug` main tlug mailing list generated archives.
- `ML.1` etc.: Spurious files from a bug; see below.
- `MLlingo`: `tlug-lingo` list generated archives.
- `images/`, `*.html`, etc.: Static informational pages.
- `robots.txt`

### Content Not Fetched

The following parts of the site are not fetched. (These are listed in
`robots.txt` so we don't need to do anything special to avoid fetching
them.)

* `/MLadm/`: Archives of private mailing lists; requires HTTP authentication.
* `/mailman/`: Mailman user interface.
* `/cgi-bin/`: Not sure what's in here, but we probably don't want to poke it.


Site Scraping
-------------

Scrape runs wget in `--no-verbose` mode by default, which means it
will not print messages for each page accessed, only errors. This can
cause it to be silent for long periods of time. Any command-line
parameters you pass to Scrape will be passed on to `wget` between the
options and the site name, so you can pass `-nv` to restore the
default verbose mode, `-q` to make output completely silent, and so on.

### Bugs and Issues

Files such as `lists.tlug.jp/ML.1` appear which are exact copies of
`lists.tlug.jp/ML/index.html`. This may be related to `/` and
`/index.html` serving the same thing, though `wget` does understand
this (see the `--default-page` option).

