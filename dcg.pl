% --- WordNet Knowledge Base Loading ---
:- discontiguous s/4.
:- discontiguous s/6.
:- discontiguous hyp/2.
:- discontiguous mm/2.
:- discontiguous sentence/2.
:- discontiguous has_part/2. 

:- consult('/home/drk/Desktop/Semantics/wordnet_project/prolog/wn_s.pl').
:- consult('/home/drk/Desktop/Semantics/wordnet_project/prolog/wn_hyp.pl').
:- consult('/home/drk/Desktop/Semantics/wordnet_project/prolog/wn_mm.pl').
:- consult('/home/drk/Desktop/Semantics/wordnet_project/WNprolog-3.0/prolog/wn_sk.pl').
:- consult('/home/drk/Desktop/Semantics/wordnet_project/wn_sk.pl').

% --- Simple grammar (no LF) ---
/* sentence --> noun_phrase, verb_phrase.
noun_phrase --> det, noun.
verb_phrase --> verb, noun_phrase.

det --> [the].
det --> [a].
det --> [an].

noun --> [W], { s(_, _, W, n, _, _) }.
verb --> [W], { verb_base(W, _) }.
verb_base(eats,  eat).
verb_base(reads, read).
verb_base(W, W) :- s(_, _, W, v, _, _). */



% --- Grammar with Logical Form ---
sentence(LF) --> noun_phrase(Subj), verb_phrase(Subj, LF).
noun_phrase(N) --> det, noun(N).
verb_phrase(Subj, LF) --> verb(V), noun_phrase(Obj),
    { LF =.. [V, Subj, Obj] }.

verb_phrase(Subj, isa(Subj, Class)) --> [is], det, noun(Class).
verb_phrase(Subj, has(Subj, Part))  --> [has], [Part].


noun(W) --> [W], { s(_, _, W, n, _, _) }.
verb(V) --> [W], { verb_base(W, V) }.


det --> [the].
det --> [a].
det --> [an].

verb_base(eats,  eat).
verb_base(reads, read).
verb_base(drinks, drink).
verb_base(writes, write).
verb_base(W, W) :- s(_, _, W, v, _, _).

% --- IS-A via WordNet hyponymy ---
is_a(X, Y) :-
    s(XID, 1, X, n, _, _),
    s(YID, 1, Y, n, _, _),
    XID \= YID,
    isa_path(XID, YID, [XID]).

% base case - when we reach the goal, stop
isa_path(ID, ID, _).

% recursive case - climb one step up
isa_path(Cur, Goal, Visited) :-
    hyp(Cur, Parent),
    \+ member(Parent, Visited),
    isa_path(Parent, Goal, [Parent|Visited]).



% check word belongs to lexfile number
in_lexfile(Word, FileNum) :-
    sk(ID, 1, SenseKey),
    s(ID, 1, Word, n, _, _),
    sub_atom(SenseKey, _, 2, _, FileAtom),
    atom_number(FileAtom, FileNum).

% sintagmatic truth check
sentence(Words, []) :-
    phrase(sentence(LF), Words),
    LF =.. [V, Subj, Obj],
    sel(V, subject, SF),
    sel(V, object,  OF),
    in_lexfile(Subj, SF),
    in_lexfile(Obj,  OF).

% --- sintagmatic truth check ---
sentence(Words, []) :-
    phrase(sentence(LF), Words),
    LF =.. [V, Subj, Obj],
    sel(V, subject, SC),
    sel(V, object,  OC),
    is_a(Subj, SC),
    is_a(Obj,  OC).

%Exercise 3 — Paradigmatic relations 

% for "is" questions - use is_a
sentence(Words, []) :-
    phrase(sentence(isa(Subj, Class)), Words), !,
    is_a(Subj, Class).

% for "has" questions - use wn_mm meronymy
sentence(Words, []) :-
    phrase(sentence(has(Subj, Part)), Words), !,
    has_part(Subj, Part).

% --- HAS-PART via WordNet meronymy ---
/* has_part(Whole, Part) :-
    s(WID, 1, Whole, n, _, _),
    s(PID, 1, Part,  n, _, _),
    wn_mm(WID, PID, _).

has_part(Whole, PluralPart) :-
    atom_concat(Whole, s, PluralPart). */

% HAS-PART via WordNet meronymy (transitive) 
has_part(Whole, Part) :-
    s(WID, 1, Whole, n, _, _),
    s(PID, 1, Part,  n, _, _),
    mm_path(WID, PID, [WID]).

% Base case: direct part relation
mm_path(WID, PID, _) :-
    mm(WID, PID).

% Recursive case: follow the chain
mm_path(WID, PID, Visited) :-
    mm(WID, MID),
    \+ member(MID, Visited),
    mm_path(MID, PID, [MID|Visited]).

% handle plurals
has_part(Whole, PluralPart) :-
    atom_concat(Whole, s, PluralPart).

% --- Explain why a sentence is true ---
% Explain sintagmatic sentences
why(Words) :-
    phrase(sentence(LF), Words),
    LF =.. [V, Subj, Obj],
    V \= isa,
    V \= has,
    sel(V, subject, SF),
    sel(V, object,  OF),
    in_lexfile(Subj, SF),
    in_lexfile(Obj,  OF),
    s(SID, 1, Subj, n, _, _),
    s(OID, 1, Obj,  n, _, _),
    sk(SID, 1, SK1),
    sk(OID, 1, SK2),
    format("~w is in lexfile ~w via sense key ~w~n", [Subj, SF, SK1]),
    format("~w is in lexfile ~w via sense key ~w~n", [Obj,  OF, SK2]).

% Explain IS-A sentences
why(Words) :-
    phrase(sentence(isa(Subj, Class)), Words),
    is_a(Subj, Class),
    s(XID, 1, Subj,  n, _, _),
    s(YID, 1, Class, n, _, _),
    format("~w is-a ~w (synset ~w -> ~w)~n", [Subj, Class, XID, YID]).

% Explain HAS-PART sentences
why(Words) :-
    phrase(sentence(has(Subj, Part)), Words),
    has_part(Subj, Part),
    format("~w has-part ~w~n", [Subj, Part]).

% Transitive meronymy through hypernymy:
% If X has no direct parts, climb up IS-A chain and check parent's parts
has_part_via_hyp(Whole, Part) :-
    has_part(Whole, Part).
has_part_via_hyp(Whole, Part) :-
    s(WID, 1, Whole, n, _, _),
    hyp(WID, ParentID),
    s(ParentID, 1, Parent, n, _, _),
    has_part(Parent, Part)..
