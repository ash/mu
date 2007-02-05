package main;

use lib '../v6-MiniPerl6/lib5', 'lib5', '.';
use strict;

BEGIN {
    $::_V6_COMPILER_NAME    = 'KindaPerl6';
    $::_V6_COMPILER_VERSION = '0.001';
}

use KindaPerl6::Perl5::Runtime;
use KindaPerl6::Perl5::Match;

package Main;
use KindaPerl6::Grammar;

use KindaPerl6::Traverse;
use KindaPerl6::Visitor::LexicalSub;
use KindaPerl6::Visitor::Perl;
use KindaPerl6::Visitor::EmitPerl5;
use KindaPerl6::Visitor::Hyper;
use KindaPerl6::Visitor::MetaClass;
use KindaPerl6::Visitor::CreateEnv; 

use KindaPerl6::Grammar::Regex;
use KindaPerl6::Emitter::Token;

my $source = join('', <> );
my $pos = 0;

say( "# Do not edit this file - Generated by KindaPerl6" );
say( "use v5;" );
say( "use strict;" );
say( "use KindaPerl6::Perl5::Runtime;" );
say( "use KindaPerl6::Perl5::Match;" );

my $visitor_lexical_sub = KindaPerl6::Visitor::LexicalSub->new();
my $visitor_create_env  = KindaPerl6::Visitor::CreateEnv->new();
my $visitor_dump_ast    = KindaPerl6::Visitor::Perl->new();
my $visitor_hyper       = KindaPerl6::Visitor::Hyper->new();
my $visitor_emit_perl5  = KindaPerl6::Visitor::EmitPerl5->new();
my $visitor_metamodel   = KindaPerl6::Visitor::MetaClass->new();

use Data::Dump::Streamer;

while ( $pos < length( $source ) ) {
    #say( "Source code:", $source );
    my $p = KindaPerl6::Grammar->comp_unit($source, $pos);
    #say( Main::perl( $$p ) );
    my @ast = $$p;
    @ast = map { $_->emit( $visitor_lexical_sub )     } @ast;
    #print Dump ( @ast );
    @ast = map { $_->emit( $visitor_metamodel )       } @ast;
    @ast = map { $_->emit( $visitor_create_env )      } @ast;
    print Dump( @ast );
    #say( join( ";\n", (map { $_->emit( $visitor_dump_ast    ) } @ast )));

    print "\nPerl 5 code:\n-------\n";
    say( join( ";\n", (map { $_->emit( $visitor_emit_perl5  ) } (@ast) )));

    #say( $p->to, " -- ", length($source) );
    say( ";" );
    $pos = $p->to;
}

say "1;";
