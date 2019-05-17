Scrape of TLUG List Archive Site
--------------------------------

This repo contains a top-level script, `Scrape`, which fetches all
(publicly available) files served by <https://lists.tlug.jp>, and the
scraped content, which is updated on an ad-hoc basis by whoever feels
like doing it.


Site Content
------------

All content fetched from the site is under `lists.tlug.jp/`.

- `/ML/`: `tlug` main tlug mailing list generated archives.
- `/ML.1` etc.: Spurious files from a bug; see below.
- `/MLlingo/`: `tlug-lingo` list generated archives.
- `/images/`, `*.html`, etc.: Static informational pages.
- `/robots.txt`

### Content Not Fetched

The following parts of the site are not fetched. (These are listed in
`robots.txt` so we don't need to do anything special to avoid fetching
them.)

- `/MLadm/`: Archives of private mailing lists; requires HTTP authentication.
- `/mailman/`: Mailman user interface.
- `/cgi-bin/`: Not sure what's in here, but we probably don't want to poke it.


Site Scraping
-------------

Scrape runs wget in `--no-verbose` mode by default, which means it
will not print messages for each page accessed, only errors. This can
cause it to be silent for long periods of time. Any command-line
parameters you pass to Scrape will be passed on to `wget` between the
options and the site name, so you can pass `-nv` to restore the
default verbose mode, `-q` to make output completely silent, and so on.

### Bugs and Issues

Files not on the actual site like `lists.tlug.jp/ML.1` are created by
wget; they are exact copies of `lists.tlug.jp/ML/index.html`. This may
be related to `/` and `/index.html` serving the same thing, though
`wget` does understand this (see the `--default-page` option).

These are currently removed by the `Scrape` script when it exits,
whether or not `wget` completed successfully.


Netlify Deployment
------------------

The [`lists-tlug-jp`] site in the [TLUG Netlify account][netlify] is
configured to serve the `master` branch of this repo.

The download and no-op "build" is very fast, so the only time it
should take to deploy is the time to upload changed files.

### Netlify Initial Deployment

On the initial deployment with a new Netlify site, it printed "72962
new files to upload" and then failed after 29 minutes of uploading
with "Build exceeded maximum allowed runtime." Re-running the deploy
then printed "55968 new files to upload" and eventually failed again.
The last run had 26720 files to upload, which printed "Finished
processing build request in 21m27.171124307s," at which point it took
an additional three hours with status as "uploading" in the list of
all deploys before the site went live.



<!-------------------------------------------------------------------->
[netlify]: https://github.com/tlug/tlug.jp/blob/master/doc/hosting.md
[`lists-tlug-jp`]: https://lists-tlug-jp.netlify.com
