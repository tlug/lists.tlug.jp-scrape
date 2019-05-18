Scrape of TLUG List Archive Site
--------------------------------

This repo contains a top-level script, `Scrape`, which fetches all
(publicly available) files served by <https://lists.tlug.jp>, and the
scraped content, which is updated on an ad-hoc basis by whoever feels
like doing it.


Repo Contents
-------------

- `README.md`: This file.
- `lists.tlug.jp/`: Scraped copy of all files on <http://lists.tlug.jp>.
- `Scrape`: Scrapes the site and updates `lists.tlug.jp/`.
- `Size`: Show disk space usage and number of files under `lists.tlug.jp/`.
- `netlify.toml`: Configuration for serving `lists.tlug.jp/` as a
  static site on [Netlify](https://netlify.com).
- `tmp/`: Ignored, so never committed. Useful for storing work files
  you do not want accidentally to commit.


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
- `/cgi-bin/`


Missing Functionality
---------------------

When served as a static site, the following functionality is missing
as compared to the legacy `lists.tlug.jp`.

- `tlug-admin` list archives. This is easy to add if we're willing to
  make some compromises about the password protection. See above and
  below for more information on this.
- List archive search of `tlug-admin` pages. (Not configured for the
  other lists, for some reason.) This called `/cgi-bin/htsearch`.
  Probably should be removed; we already have Google custom search on
  the top page. Could probably be replaced by external Google, Duck
  Duck Go, etc. search.
- List management functionality: `/mailman/*`. Does not, at a quick
  glance, appear to use any scripts under `/cgi-bin`, but the server
  config file should be checked.
- `/cgi-bin/*`: Other stuff we don't know about?


Site Scraping
-------------

Any command-line parameters you pass to Scrape will be passed on to
`wget` between the options and the site name. This lets you override
the default `wget` options used by `Scrape` and add additional ones.

Scrape has `wget` log to a file (with a timestamp in the name) under
`log/`, thus the script should normally produce no output and can be
safely run in the background. If you want to restore the standard
`wget` behaviour of logging to standard error, use `-o /dev/stderr`.

Scrape runs wget in `--no-verbose` mode by default, which means it
will not log messages for each page accessed, only errors. Use `-nv`
to restore the default verbose mode, or `-q` to do no logging at all.
(The log file will still be created, however.)

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
