UnicodeCodePoints
=================

Unicode code points rudimentary conversion to and from UTF-8.

Implementation based on http://en.wikipedia.org/wiki/UTF-8 (Modified UTF-8).

License at the top of the module.

EXPORTS
=======

detect/1:

- accepts plain list of integers<br/>
- checks against Unicode codepoints<br/>
- returns one of the following atoms<br/>
---> 'unknown': failed both UCP and UTF-8 tests<br/>
---> 'either': all the integers are less 128, but larger than 1<br/>
---> 'utf8': all UTF-8 sequence tests passed, no UCP specific integers detected<br/>
---> 'ucp': all UCP tests passed, no UTF-8 sequence found<br/>
---> 'mixed': found a mix between UTF-8 sequences and UCP specific integers

to_utf8/1:

- accepts UCP list of integers<br/>
- returns UTF-8 encoded list or crashes if the input is not a correct UCP list

from_utf8/1

- accepts UTF-8 list of integers<br/>
- returns UCP list or crashes if the input is not a correct UTF-8 list

NOTES
=====

1. UCP/ucp = Unicode code points.<br/>
2. UTF-8 is using a sequence of bytes to encode the UCP's in that region. That<br/>
doesn't mean that it cannot be a simple coincidence (pretty nasty one though)<br/>
with a sequence of UCP's in the region of Latin-1.
3. This module intention is not to overlap with unicode module from Erlang, but<br/>
to allow the users to have control over their lists denoting some strings.<br/>
Erlang in this moment is relying on the environment to extract the integers for<br/>
the string-list and that makes unicode unreliable for the moment. The issue is<br/>
known and it will be fixed soon (hopefully).

