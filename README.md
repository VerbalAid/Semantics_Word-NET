# Semantic Interpretation using Prolog DCG and WordNet

**Student:** Darragh Kerins  
**Course:** Semantics / Knowledge Representation — UPV/EHU

---

## Files
- `dcg.pl` — main Prolog file containing all four assignments
- `wn_sk.pl` — selectional preferences mapped to WordNet lexicographic file numbers

## WordNet Setup
The WordNet Prolog files are not included due to their size. Download from:  
https://wordnetcode.princeton.edu/3.0/WNprolog-3.0.tar.gz  
Update the five `consult` paths at the top of `dcg.pl` to match your local installation, then run:
```bash
swipl dcg.pl
```

---

## Assignment 1 — WordNet Integration + Logical Form

The grammar is integrated with the WordNet lexicon so any noun in WordNet is valid, and verbs map to their base form. Sentences produce a logical form (LF).

```prolog
phrase(sentence(LF), [the,cat,eats,a,fish]).
% LF = eat(cat,fish)
```

---

## Assignment 2 — Sintagmatic Relations

Selectional preferences are encoded in `wn_sk.pl` using WordNet lexicographic file numbers (e.g. file 5 = animals, file 13 = food/plants). A sentence is accepted if subject and object belong to the correct files for that verb.

```prolog
sentence([a,monkey,eats,a,banana], []).   % true
sentence([a,monkey,eats,a,book], []).     % false
sentence([a,doctor,reads,a,book], []).    % true
sentence([a,doctor,reads,a,banana], []).  % false
```

---

## Assignment 3 — Paradigmatic Relations

IS-A uses transitive hyponymy from WordNet (`wn_hyp.pl`). HAS-PART uses transitive meronymy (`wn_mm.pl`).

```prolog
sentence([an,apple,is,a,fruit], []).      % true
sentence([an,apple,is,an,animal], []).    % false
sentence([an,apple,has,apples], []).      % true
sentence([an,apple,has,fingers], []).     % false
```

---

## Assignment 4 — Extensions

**Explain why** a sentence is true (which senses and relations hold):
```prolog
why([a,monkey,eats,a,banana]).
why([an,apple,is,a,fruit]).
why([an,apple,has,apples]).
```

**Transitive meronymy** — `mm_path/3` follows part-of chains recursively through WordNet.

**Transitive meronymy through hypernymy** — `has_part_via_hyp/2` climbs the IS-A chain to inherit parts from parent synsets (e.g. orchard apple tree inherits leaves from apple tree → plant).
