# learnvimscriptthehardway-docset

A shell-script that builds the *Learn VimScript the Hard Way* docs into
a Dash.app Docset.

## Setup

```console
    $ ROOT=/path/to/checkouts
    $ cd $ROOT
    $ git clone https://github.com/sjl/learnvimscriptthehardway.git
    $ git clone https://github.com/sjl/bookmarkdown.git
    $ git clone https://github.com/bsandrow/learnvimscriptthehardway-docset.git
    $ cd bookmarkdown
    $ mkvirtualenv bookmarkdown
    $ pip install -r requirements.txt
    $ cd ../learnvimscriptthehardway-docset
    $ ./build.sh ../learnvimscriptthehardway
```
