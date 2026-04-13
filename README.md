# Prolog DCG WordNet Assignment

DCG grammar integrated with WordNet for commonsense reasoning.

## Requirements
- SWI-Prolog
- WordNet Prolog files (WNprolog-3.0): https://wordnetcode.princeton.edu/3.0/WNprolog-3.0.tar.gz

## Files
- `dcg.pl` — main grammar with logical form, sintagmatic and paradigmatic relations
- `wn_sk.pl` — selectional preferences by WordNet lexicographic file number
- `valid_sentences.txt` — example valid sentences

## Usage
```prolog
swipl dcg.pl
sentence([a,monkey,eats,a,banana], []).
sentence([an,apple,is,a,fruit], []).
why([a,monkey,eats,a,banana]).
```
