Minimalistic console dictionary using only shell and UNIX command line
utilities.

Script uses a simple custom dictionary format where each entry is defined on a
separate line so that `look` (binary search) can be used. Pattern-based search
using `grep` is also supported. Results are displayed using `less` with
highlighted search pattern.


Installation
------------

1. `cp bin/shdic.sh ~/bin/`
2. Create an empty folder `~/.local/share/shdic` and add dictionaries as
   described below.


Usage
-----

### Conversion of dictionaries

- Convert dictionary from `tei` format (http://freedict.org/): `shdic.sh convert_tei
  <dictionary>.tei ~/.local/share/shdic/<dictionary>`.

- Convert dictionary from `dictd` format
  (http://mueller-dict.sourceforge.net/): `shdic.sh convert_mueller
  <dictionary>.dict.dz ~/.local/share/shdic/<dictionary>`.


### Search
- Match a word exactly: `shdic.sh <dictionary> exactmatch <word>`, where
  `<dictionary>` is a filename in `~/.local/share/shdic`
- Match words using a pattern: `shdic.sh <dictionary> wordsearch <pattern>`
- Search for a given pattern everywhere: `shdic.sh <dictionary> fullsearch <pattern>`

If command or both command and dictionary are omitted -- the defaults specified
in `shdic.sh` are used.
