Scrape of TLUG List Archive Site
--------------------------------

This repo contains a top-level script, `Scrape`, which fetches all
(publicly available) files served by <https://lists.tlug.jp>, and a
`lists.tlug.jp` directory containing the site fetched with that
script as of some point recently before the most recent commit.

Scrape runs wget in `--no-verbose` mode by default, which means it
will not print messages for each page accessed, only errors. This can
cause it to be silent for long periods of time. Any command-line
parameters you pass to Scrape will be passed on to `wget` between the
options and the site name, so you can pass `-nv` to restore the
default verbose mode, `-q` to make output completely silent, and so on.
