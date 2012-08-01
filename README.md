UnicodeCodePoints
=================

Latin-1 rudimentary conversion to and from UTF-8.

Implementation based on http://en.wikipedia.org/wiki/UTF-8 (Modified UTF-8).

License at the top of the module.

EXPORTS
=======

detect/1:

- accepts plain list of integers<br/>
- checks against Unicode codepoints<br/>
- returns one of the following atoms<br/>
---> 'unknown': failed both Latin-1 and UTF-8 tests<br/>
---> 'either': all the integers are less 128, but larger than 1<br/>
---> 'latin1': all Latin-1 tests passed, no UTF-8 specific integers detected<br/>
---> 'utf8': all UTF-8 tests passed, no Latin-1 sequence found<br/>
---> 'mixed': found a mix between Latin-1 sequences and UTF-8 specific integers

to_utf8/1:

- accepts Latin-1 list of integers<br/>
- returns UTF-8 list or crashes if the input is not a correct Latin-1 list

from_utf8/1

- accepts UTF-8 list of integers<br/>
- returns Latin-1 list or crashes if the input is not a correct UTF-8 list

NOTES
=====

1. Due to the overlap in between Latin-1 and UTF-8 for integers in between 128<br/>
and 245, treat detect/1 output 'latin1' only as the input list passed all the <br/>
Latin-1 tests and do not discard the possibility to have an UTF-8 sequence which<br/>
may coincide with a Latin-1 sequence.<br/>
2. Remember, this is just a rudimentary check which I hope will help the Erlang<br/>
users until something better appears.

