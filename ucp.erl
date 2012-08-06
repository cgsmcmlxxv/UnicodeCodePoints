%% ===================================================================
%% Project: UnicodeCodePoints
%% File: ucp.erl
%% Description: A simple detection of and conversion in between
%%              Unicode code points and UTF-8 encoding
%% Author: CGSMCMLXXV <cgsmcmlxxv@gmail.com>
%% Copyright: 2012 CGSMCMLXXV
%% License: GNU GPL3 (if something else is needed, drop an e-mail)
%% ===================================================================


-module(ucp).

-export([detect/1,to_utf8/1,from_utf8/1]).

detect(L)
when is_list(L) ->
    test(L,false,false,true).

test([],true,true,_) ->
    mixed;

test([],true,false,_) ->
    utf8;

test([],false,true,_) ->
    ucp;

test([],false,false,true) ->
    either;

test([],false,false,false) ->
    unknown;

test([H|T],UCP,UTF8,EITHER) ->
    case is_integer(H) of
        false ->
            test([],false,false,false);
        true ->
            case H of
                I when (I < 0) or (I > 2097151) or ((H > 56447) and (H < 56576)) -> test([],false,false,false);
                I when I == 0 -> test(T,UCP,true,EITHER);
                I when I < 128 -> test(T,UCP,UTF8,true);
                I when I > 128, I < 192 -> test(T,UCP,true,EITHER);
                I when I == 192 -> test_for_zero(T,UCP,UTF8);
                I when I > 192, I < 194 -> test(T,UCP,true,EITHER);
                I when I > 193, I < 224 -> test_one_byte(T,UCP,UTF8);
                I when I > 224, I < 240 -> test_two_bytes(H,T,UCP,UTF8);
                I when I > 239, I < 245 -> test_three_bytes(H,T,UCP,UTF8);
                _ELSE -> test(T,UCP,true,false)
            end
    end.

test_for_zero([],UCP,_) ->
    test([],UCP,true,false);

test_for_zero([H|T],UCP,UTF8) ->
    case is_integer(H) of
        false ->
            test([],false,false,false);
        true ->
            case H == 128 of
                true -> test(T,true,UTF8,true);
                false -> test([H|T],UCP,true,false)
            end
    end.

test_one_byte([],UCP,_) ->
    test([],UCP,true,false);

test_one_byte([H|T],UCP,UTF8) ->
    case is_integer(H) of
        false ->
            test([],false,false,false);
        true ->
            case (H > 127) and (H < 192)  of
                true -> test(T,true,UTF8,true);
                false -> test([H|T],UCP,true,false)
            end
    end.

test_two_bytes(_,[],UCP,_) ->
    test([],UCP,true,false);

test_two_bytes(_,[H],UCP,_) ->
    test([H],UCP,true,false);

test_two_bytes(H,[H1,H2|T],UCP,UTF8) ->
    case is_integer(H1) and is_integer(H2) of
        false ->
            test([],false,false,false);
        true ->
            case H of
                I when I == 224 ->
                    case (H1 > 159) and (H1 < 192) and (H2 > 127) and (H2 < 192) of
                        true -> test(T,true,UTF8,true);
                        false -> test([H1,H2|T],UCP,true,false)
                    end;
                I when ((I > 224) and (I < 237)) or (I > 237) ->
                    case (H1 > 127) and (H1 < 192) and (H2 > 127) and (H2 < 192) of
                        true -> test(T,true,UTF8,true);
                        false -> test([H1,H2|T],UCP,true,false)
                    end;
                I when I == 237 ->
                    case (((H1 > 127) and (H1 < 178)) or ((H1 > 183) and (H1 < 191))) and (H2 > 127) and (H2 < 192) of
                        true -> test(T,true,UTF8,true);
                        false -> test([H1,H2|T],UCP,true,false)
                    end
            end
    end.

test_three_bytes(_,[],UCP,_) ->
    test([],UCP,true,false);

test_three_bytes(_,[H],UCP,_) ->
    test([H],UCP,true,false);

test_three_bytes(_,[H1,H2],UCP,_) ->
    test([H1,H2],UCP,true,false);

test_three_bytes(H,[H1,H2,H3|T],UCP,UTF8) ->
    case is_integer(H1) and is_integer(H2) and is_integer(H3) of
        false ->
            test([],false,false,false);
        true ->
            case H == 240 of
                true ->
                    case (H1 > 143) and (H1 < 192) and (H2 > 127) and (H2 < 192) and (H3 > 127) and (H3 < 192) of
                        true -> test(T,true,UTF8,true);
                        false -> test([H1,H2,H3|T],UCP,true,false)
                    end;
                false ->
                    case (H1 > 127) and (H1 < 192) and (H2 > 127) and (H2 < 192) and (H3 > 127) and (H3 < 192) of
                        true -> test(T,true,UTF8,true);
                        false -> test([H1,H2,H3|T],UCP,true,false)
                    end
            end
    end.

to_utf8(L)
when is_list(L) ->
    lists:reverse(to_utf8(lists:reverse(L),[])).

to_utf8([],[]) ->
    [];

to_utf8([H|T],[])
when is_integer(H) ->
    case H of
        I when I == 0 -> [128|to_utf8(T,[192])];
        I when I > 0, I < 128 -> [H|to_utf8(T,[])];
        I when I > 127, I < 2048 -> [128 + (H rem 64)|to_utf8(T,[192 + (H bsr 6)])];
        I when I > 2047, I < 56448 -> [128 + (H rem 64)|to_utf8(T,[128 + ((H bsr 6) rem 64),224 + (H bsr 12)])];
        I when I > 56575, I < 65536 -> [128 + (H rem 64)|to_utf8(T,[128 + ((H bsr 6) rem 64),224 + (H bsr 12)])];
        I when I > 65535, I < 2097152 -> [128 + (H rem 64)|to_utf8(T,[128 + ((H bsr 6) rem 64),240 + ((H bsr 12) rem 64),192 + (H bsr 18)])]
    end;

to_utf8(L,[H]) ->
    [H|to_utf8(L,[])];

to_utf8(L,[H|T]) ->
    [H|to_utf8(L,T)].

from_utf8(L)
when is_list(L) ->
    from_utf8_1(L).

from_utf8_1([]) ->
    [];

from_utf8_1([H|T])
when is_integer(H) ->
    case H of
        I when I > 0, I < 128 -> [H|from_utf8_1(T)];
        I when I == 192 -> check_for_zero([H|T]);
        I when I > 193, I < 224 -> two_bytes([H|T]);
        I when I > 223, I < 240 -> three_bytes([H|T]);
        I when I > 239, I < 245 -> four_bytes([H|T])
    end.

check_for_zero([_,H2|T])
when H2 == 128 ->
    [0|from_utf8_1(T)].

two_bytes([H1,H2|T])
when H2 > 127,
     H2 < 192 ->
    [((H1 - 192) bsl 6) + H2 - 128|from_utf8_1(T)].

three_bytes([H1,H2,H3|T])
when H1 == 224,
     H2 > 159,
     H2 <192,
     H3 > 127,
     H3 < 192 ->
    [((H1 - 224) bsl 12) + ((H2 - 128) bsl 6) + H3 - 128|from_utf8_1(T)];

three_bytes([H1,H2,H3|T])
when H1 > 224,
     H1 < 237,
     H2 > 127,
     H2 < 192,
     H3 > 127,
     H3 < 192 ->
    [((H1 - 224) bsl 12) + ((H2 - 128) bsl 6) + H3 - 128|from_utf8_1(T)];

three_bytes([H1,H2,H3|T])
when H1 == 237,
     H2 > 127,
     H2 < 178,
     H3 > 127,
     H3 < 192 ->
    [((H1 - 224) bsl 12) + ((H2 - 128) bsl 6) + H3 - 128|from_utf8_1(T)];

three_bytes([H1,H2,H3|T])
when H1 == 237,
     H2 > 183,
     H2 < 192,
     H3 > 127,
     H3 < 192 ->
    [((H1 - 224) bsl 12) + ((H2 - 128) bsl 6) + H3 - 128|from_utf8_1(T)];

three_bytes([H1,H2,H3|T])
when H1 > 237,
     H1 < 240,
     H2 > 127,
     H2 < 192,
     H3 > 127,
     H3 < 192 ->
    [((H1 - 224) bsl 12) + ((H2 - 128) bsl 6) + H3 - 128|from_utf8_1(T)].

four_bytes([H1,H2,H3,H4|T])
when H1 == 240,
     H2 > 143,
     H2 < 192,
     H3 > 127,
     H3 < 192,
     H4 > 127,
     H4 < 192 ->
    [((H1 - 240) bsl 18) + ((H2 - 128) bsl 12) + ((H3 - 128) bsl 6) + H4 - 128 |from_utf8_1(T)];

four_bytes([H1,H2,H3,H4|T])
when H1 > 240,
     H1 < 245,
     H2 > 127,
     H2 < 192,
     H3 > 127,
     H3 < 192,
     H4 > 127,
     H4 < 192 ->
    [((H1 - 240) bsl 18) + ((H2 - 128) bsl 12) + ((H3 - 128) bsl 6) + H4 - 128 |from_utf8_1(T)].





