# tests for single-stepping - fglock

use strict;
use warnings;

use Test::More tests => 37;
use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Pad      = '# ';
$Data::Dumper::Sortkeys = 1;

use_ok( 'Pugs::Runtime::Regex' );
use Pugs::Runtime::Match;

{
  my $match;
  my $rule = Pugs::Runtime::Regex::constant( 'a' );
  
  $rule->( 'a123', undef, {capture=>1, single_step=>1}, $match );
    #print Dumper( $match );
    ok ( $match->bool, "a =~ /a/ #1" );
    is ( $match->tail, '123', "tail is ok" );
    ok ( !defined($match->state), "no more states" );
    
  $rule->( 'c', undef, {capture=>1}, $match );
    ok ( ! $match->bool, "c =~ /a/ #2" );
    
  $rule->( 'ca', undef, {}, $match);
    ok( !$match->bool, "anchored match" );

}

{
  # -- continuations in alternation()
  my $match;
  my $rule = 
      Pugs::Runtime::Regex::alternation( [
        Pugs::Runtime::Regex::constant( 'x' ), 
        Pugs::Runtime::Regex::constant( 'a' ), 
        Pugs::Runtime::Regex::constant( 'ab' ), 
      ] );
  my $str = 'ab';

  $rule->( $str, undef, {}, $match );
    #print "state: ", Dumper($match->state), "\n";
    is ( $match->str, '', "/[a|ab]/ alternation continuation state #0 - no match" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "# state: ", Dumper($match->state), "\n";
    is ( $match->str, 'a', "state #1" );
    ok ( $match, "match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "# state: ", Dumper($match->state), "\n";
    is ( $match->str, 'ab', "state #2" );
    ok ( $match, "match" );
    ok ( !defined($match->state), "no more states" );

}

{
  # -- continuations in concat()
  my $match;
  my $rule = 
    Pugs::Runtime::Regex::concat( [
      Pugs::Runtime::Regex::alternation( [
        Pugs::Runtime::Regex::constant( 'a' ), 
        Pugs::Runtime::Regex::constant( 'ab' ), 
      ] ),
      Pugs::Runtime::Regex::alternation( [
        Pugs::Runtime::Regex::constant( 'x' ), 
        Pugs::Runtime::Regex::constant( 'bb' ), 
      ] ),
    ] );
  my $str = 'abbb';
  # expected: (a) (fail) (a,bb) (ab) (fail) (ab,bb)
  
  $rule->( $str, undef, {}, $match );
    #print "state 1: ", Dumper($match->state), "\n";
    is ( $match->str, '', "$str ~~ /[a|ab][x|bb]/ continuation state #0" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 2: ", Dumper($match->state), "\n";
    is ( $match->str, '', "state #2" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 3: ", Dumper($match->state), "\n";
    is ( $match->str, 'abb', "state #3" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 4: ", Dumper($match->state), "\n";
    is ( $match->str, '', "state #4" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 5: ", Dumper($match->state), "\n";
    is ( $match->str, '', "state #5" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 6: ", Dumper($match->state), "\n";
    is ( $match->str, 'abbb', "state #6" );
    ok ( !defined($match->state), "no more states" );

}

{
  # -- continuations in parallel_alternation()
  my $match;
  my $rule = 
    Pugs::Runtime::Regex::parallel_alternation( [
      Pugs::Runtime::Regex::concat( [
        Pugs::Runtime::Regex::constant( 'a' ), 
        Pugs::Runtime::Regex::constant( 'bb' ), 
      ] ),
      Pugs::Runtime::Regex::concat( [
        Pugs::Runtime::Regex::constant( 'ab' ), 
        Pugs::Runtime::Regex::constant( 'bb' ), 
      ] ),
    ] );
  my $str = 'abbb';
  # expected: (a|ab) (abb|abbb) -> longest token = abbb
  
  $rule->( $str, undef, {}, $match );
    #print "state 1: ", Dumper($match->state), "\n";
    is ( $match->str, '', "$str ~~ /a bb | ab bb/ parallel_alternation state #0" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 2: ", Dumper($match->state), "\n";
    is ( $match->str, 'abbb', "state #2" );
    ok ( !defined($match->state), "no more states" );

}

{
  # -- continuations in optional()
  my $match;
  my $rule = 
    Pugs::Runtime::Regex::optional( 
      Pugs::Runtime::Regex::constant( 'a' ), 
    );
  my $str = 'abbb';
  # expected: (a) ()
  
  $rule->( $str, undef, {}, $match );
    #print "state 1: ", Dumper($match->state), "\n";
    is ( $match->str, 'a', "$str ~~ /a?/ optional state #0" );
    ok ( $match, "match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 2: ", Dumper($match->state), "\n";
    is ( $match->str, '', "state #2" );
    ok ( $match, "match" );
    ok ( !defined($match->state), "no more states" );

}

{
  # -- continuations in a*
  my $match;
  my $rule = 
    Pugs::Runtime::Regex::greedy_star( 
      Pugs::Runtime::Regex::constant( 'a' ),
      0, 
      3,
    );
  my $str = 'aaa';
  
  $rule->( $str, undef, {}, $match );
    print "state 1: ", Dumper($match->state), "\n";
    is ( $match->str, '', "$str ~~ /a*/ state #0" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 2: ", Dumper($match->state), "\n";
    is ( $match->str, '', "state #2" );
    ok ( !$match, "don't match" );
    ok ( defined($match->state), "more states" );

  $rule->( $str, $match->state, {}, $match );
    #print "state 3: ", Dumper($match->state), "\n";
    is ( $match->str, 'aaa', "state #3" );
    ok ( $match ? 1 : 0 , "matched" );
    ok ( defined($match->state), "more states - can backtrack if needed" );

    for my $i ( 4..5 ) {
      $rule->( $str, $match->state, {}, $match );
        #print "state $i: ", Dumper($match->state), "\n";
        print "match: $i '$match'\n";
        #is ( $match->str, 'aaa', "state #$i" );
        #ok ( $match ? 1 : 0 , "matched" );
        #ok ( defined($match->state), "more states - can backtrack if needed" );
    }

}

__END__

{
  $rule = 
    Pugs::Runtime::Regex::greedy_star( 
      Pugs::Runtime::Regex::constant( 'a' ) 
    );
  is ( ref $rule, "CODE", "rule 'a*' is a coderef" );
  $rule->( 'aa', undef, {}, $match );
  #print Dumper( $match );
  ok ( $match->bool, "/a*/" );
  #print Dumper( $match );
  is ( $match->str, 'aa' );
  $rule->( 'aaaaab', undef, {}, $match );
  ok ($match->bool, "/a*/" );
  is ($match->str, 'aaaaa');
  $rule->( '', undef, {}, $match );
  ok ( $match->bool, "matches 0 occurrences" );
  #print Dumper( $match );
}

{
  $rule = 
    Pugs::Runtime::Regex::greedy_plus( 
      Pugs::Runtime::Regex::constant( 'a' ) 
    );
  $rule->( 'aa', undef, {}, $match );
  ok ( $match->bool, "/a+/" );
  is ( $match->str, 'aa' );
  $rule->( '!!', undef, {}, $match );
  ok ( ! $match->bool, "rejects unmatching text" );
}

{
  $rule = 
    Pugs::Runtime::Regex::greedy_plus( 
      Pugs::Runtime::Regex::constant( 'a' ),
      3, 
    );
  $rule->( 'aaaa', undef, {}, $match );
  is ( "$match", "aaaa", "/a**{3..*}/" );
  $rule->( 'aaa', undef, {}, $match );
  is ( "$match", "aaa", "/a**{3..*}/" );
  $rule->( 'aa', undef, {}, $match );
  ok ( ! $match->bool, "rejects unmatching text" );
}

{
  $rule = 
    Pugs::Runtime::Regex::concat( 
      Pugs::Runtime::Regex::greedy_plus( 
        Pugs::Runtime::Regex::alternation( [
          Pugs::Runtime::Regex::constant( 'a' ), 
          Pugs::Runtime::Regex::constant( 'c' ), 
        ] ),
      ),
      Pugs::Runtime::Regex::constant( 'ab' )
     );
  $rule->( 'aacaab', undef, {}, $match );
  ok ( $match->bool, "/[a|c]+ab/ with backtracking" );
  is ( $match->str, 'aacaab', 'all the chars accepted' );
  # print Dumper( $match );
}

{
  $rule = 
    Pugs::Runtime::Regex::non_greedy_plus( 
      Pugs::Runtime::Regex::alternation( [
        Pugs::Runtime::Regex::constant( 'a' ), 
        Pugs::Runtime::Regex::constant( 'c' ), 
      ] ),
    );
  $rule->( 'aacaab', undef, {capture=>1}, $match );
  ok ( $match, "/[a|c]+?/" );
  is ( $match->tail, 'acaab', "tail is ok" );
  #print Dumper( $match );
  $rule->( 'cacab', undef, {}, $match );
  ok $match->bool;
  is $match->str, 'c';
}

{
  $rule = 
    Pugs::Runtime::Regex::concat(
      Pugs::Runtime::Regex::non_greedy_plus( 
        Pugs::Runtime::Regex::alternation( [
          Pugs::Runtime::Regex::constant( 'a' ), 
          Pugs::Runtime::Regex::constant( 'c' ), 
        ] ),
      ),
      Pugs::Runtime::Regex::constant( 'cb' )
    );
  $rule->( 'aacacb', undef, {capture=>1}, $match );
  ok ( defined $match, "/[a|c]+?cb/ with backtracking" );
  #print Dumper( $match );
  is $match->str, 'aacacb';
  is $match->tail, '';
}

{
  # tests for a problem found in the '|' implementation in p6rule parser
  
  my $rule = 
    Pugs::Runtime::Regex::constant( 'a' );
  my $alt = 
    Pugs::Runtime::Regex::concat(
        $rule,
        Pugs::Runtime::Regex::optional (
            Pugs::Runtime::Regex::concat(
                Pugs::Runtime::Regex::constant( '|' ),
                $rule
            )
        )
    );
  $alt->( 'a', undef, {capture=>1}, $match );
  ok ( defined $match, "/a[\|a]?/ #1" );
  is $match->str, 'a';
  $alt->( 'a|a', undef, {capture=>1}, $match );
  ok ( defined $match, "/a[\|a]?/ #2" );
  is $match->str, 'a|a';
  $alt->( 'a|a|a', undef, {capture=>1}, $match );
  ok ( defined $match, "/a[\|a]?/ #3" );
  is $match->str, 'a|a';

  # adding '*' caused a deep recursion error (fixed)

  $alt = 
    Pugs::Runtime::Regex::concat(
        $rule,
        Pugs::Runtime::Regex::greedy_star(
          Pugs::Runtime::Regex::concat(
              Pugs::Runtime::Regex::constant( '|' ),
              $rule
          )
        )
    );
  $alt->( 'a', undef, {capture=>1}, $match );
  ok ( $match, "/a[\|a]*/ #1" );
  is $match->str, 'a';
  $alt->( 'a|a', undef, {capture=>1}, $match );
  ok ( $match, "/a[\|a]*/ #2" );
  is $match->str, 'a|a';
  $alt->( 'a|a|a', undef, {capture=>1}, $match );
  ok ( $match, "/a[\|a]*/ #3" );
  is $match->str, 'a|a|a';
}

{
    # ranges

  $rule = 
    Pugs::Runtime::Regex::concat(
      Pugs::Runtime::Regex::non_greedy_plus( 
        Pugs::Runtime::Regex::alternation( [
          Pugs::Runtime::Regex::constant( 'a' ), 
          Pugs::Runtime::Regex::constant( 'c' ), 
        ] ),
        2, 4,  # range
      ),
      Pugs::Runtime::Regex::constant( 'cb' )
    );
  $rule->( 'aacacb', undef, {capture=>1}, $match );
  ok ( defined $match, "/[a|c]**{2..4}?cb/ with backtracking" );
  #print Dumper( $match );
  #print "Match: $match \n"; # 
  is ( "$match", "aacacb", "/[a|c]**{2..4}?cb/ with range" );
  $rule->( 'aacb', undef, {}, $match);
  is "$match", "aacb", 'a**{2..2}cb';
  $rule->( 'cccb', undef, {}, $match);
  is "$match", 'cccb', 'c**{2..2}cb';
  $rule->( 'caacb', undef, {}, $match);
  is "$match", 'caacb', '[a|c]**{3..3}cb';

  $rule = 
    Pugs::Runtime::Regex::concat(
      Pugs::Runtime::Regex::non_greedy_plus( 
        Pugs::Runtime::Regex::alternation( [
          Pugs::Runtime::Regex::constant( 'a' ), 
          Pugs::Runtime::Regex::constant( 'c' ), 
        ] ),
        1, 2,  # range
      ),
      Pugs::Runtime::Regex::constant( 'cb' )
    );
  $rule->( 'aacacb', undef, {capture=>1}, $match );
  ok ( $match ? 0 : 1, "/[a|c]**{1..2}?cb/ with bad range fails" );

  $rule = 
    Pugs::Runtime::Regex::concat(
      Pugs::Runtime::Regex::non_greedy_plus( 
        Pugs::Runtime::Regex::alternation( [
          Pugs::Runtime::Regex::constant( 'a' ), 
          Pugs::Runtime::Regex::constant( 'c' ), 
        ] ),
        5, 7,  # range
      ),
      Pugs::Runtime::Regex::constant( 'cb' )
    );
  $rule->( 'aacacb', undef, {capture=>1}, $match );
  ok ( $match ? 0 : 1, "/[a|c]**{5..7}?cb/ with bad range fails" );
}

{
  # -- concat() empty array
  $rule = 
    Pugs::Runtime::Regex::concat( [] );
  my $str = 'abbb';
  $rule->( $str, undef, {}, $match );
  #print "state 1: ", Dumper($match->state), "\n";
  is ( $match->str, '', "empty concat" );
}

