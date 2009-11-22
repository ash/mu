use v6;
use Test;
plan 11;

# L<S13/Type Casting/"whose name is a declared type, it is taken as a coercion
# to that type">

class CoercionTest {
    method Stringy  { "foo" };
    method Numeric  { 1.2   };
}

my $o = CoercionTest.new();

#?rakudo todo 'Numeric, Stringy'
is ~$o, 'foo', 'method Stringy takes care of correct stringification';
#?rakudo skip 'Numeric, Stringy'
ok +$o == 1.2, 'method Numeric takes care of correct numification';

# RT #69378
{
    class RT69378 {
        has $.x = 'working';
        method Str() { $.x }
    }
    is RT69378.new.Str, 'working', 'call to .Str works';

    class RT69378str is Str {
        has $.a = 'RT #69378';
        method Str() { $.a }
    }
    #?rakudo 2 todo 'RT 69378'
    is RT69378str.new.a, 'RT #69378', 'call to RT69378str.new properly initializes $.a';
    is RT69378str.new.Str, 'RT #69378', 'call to .Str works on "class is Str"';
}

is 1.Str.Str, "1", ".Str can be called on Str";
is "hello".Str, "hello", ".Str can be called on Str";

{
    # Not sure how to set the derived Str portion to a value, but that would be an
    # additional useful test here.
    class DerivedFromStr is Str {
        has $.a;
    }
    isa_ok DerivedFromStr.new, DerivedFromStr, 'DerivedFromStr.new isa DerivedFromStr';
    isa_ok DerivedFromStr.new, Str, 'DerivedFromStr.new isa DerivedFromStr';
    isa_ok DerivedFromStr.new.Str, DerivedFromStr, 'DerivedFromStr.new.Str isa DerivedFromStr';
    isa_ok DerivedFromStr.new.Str, Str, 'DerivedFromStr.new.Str isa Str';
}

# vim: ft=perl6
