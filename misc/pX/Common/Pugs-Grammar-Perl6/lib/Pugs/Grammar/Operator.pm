﻿package Pugs::Grammar::Operator;
use strict;
use warnings;
use base qw(Pugs::Grammar::BaseCategory);
use Pugs::Grammar::Precedence;

use Data::Dumper;

our $operator;

# TODO - implement the "magic hash" dispatcher
our %hash;

#our @subroutine_names;

BEGIN {
    $operator = Pugs::Grammar::Precedence->new( 
        grammar => 'Pugs::Grammar::Operator',
        header  => q!
attr:
        #empty  
        { $_[0]->{out}= { attribute => [] } }
    |   BAREWORD  BAREWORD  attr
        { $_[0]->{out}= { 
            attribute => [ 
                [$_[1], $_[2],],
                @{$_[3]{attribute}}, 
            ], 
        } }
    ;

stmt:  
      'if' exp '{' exp '}' 
        { $_[0]->{out}= { 'if' => { exp => $_[2], then => $_[4] } } }
    | 'if' exp '{' exp '}' else '{' exp '}'
        { $_[0]->{out}= { 'if' => { exp => $_[2], then => $_[4], else => $_[8] } } }
        
    | 'unless' exp '{' exp '}' 
        { $_[0]->{out}= { 'unless' => { exp => $_[2], then => $_[4] } } }
    | 'unless' exp '{' exp '}' else '{' exp '}'
        { $_[0]->{out}= { 'unless' => { exp => $_[2], then => $_[4], else => $_[8] } } }
        
    | 'for' exp '{' exp '}'
        { $_[0]->{out}= { 'for' => { exp => $_[2], block => $_[4], } } }
        
    | 'sub' BAREWORD             attr '{' exp '}' 
        { $_[0]->{out}= { 'sub' => { name => $_[2], block => $_[5], %{$_[3]} } } }
    | 'sub' BAREWORD '(' ')'     attr '{' exp '}' 
        { $_[0]->{out}= { 'sub' => { name => $_[2], param => {}, block => $_[7], %{$_[5]} } } }
    | 'sub' BAREWORD '(' exp ')' attr '{' exp '}' 
        {
            #print "parse-time define sub: ", Dumper( $_[2] );
            #push @subroutine_names, $_[2]->{bareword};
            #print "Subroutines: @subroutine_names\n";
            $_[0]->{out}= { 'sub' => { name => $_[2], param => $_[4], block => $_[8], %{$_[6]} } } 
        }
        
    | 'multi' BAREWORD             attr '{' exp '}' 
        { $_[0]->{out}= { 'multi' => { name => $_[2], block => $_[5], %{$_[3]} } } }
    | 'multi' BAREWORD '(' ')'     attr '{' exp '}' 
        { $_[0]->{out}= { 'multi' => { name => $_[2], param => {}, block => $_[7], %{$_[5]} } } }
    | 'multi' BAREWORD '(' exp ')' attr '{' exp '}' 
        { $_[0]->{out}= { 'multi' => { name => $_[2], param => $_[4], block => $_[8], %{$_[6]} } } }
        
    | '{' exp '}'        
        { $_[0]->{out}= { 'bare_block' => $_[2] } }
    | 'BEGIN' '{' exp '}'        
        { $_[0]->{out}= { 'BEGIN' => $_[3] } }
    | 'END' '{' exp '}'        
        { $_[0]->{out}= { 'END' => $_[3] } }
    ;
exp: 
      NUM                 
        { $_[0]->{out}= $_[1] }
        
    | BAREWORD            
        { $_[0]->{out}= { call => { sub => $_[1], } } }
    | BAREWORD exp   %prec P003
        { $_[0]->{out}= { call => { sub => $_[1], param => $_[2], } } }
    | exp '.' BAREWORD    %prec P003
        { $_[0]->{out}= { method_call => { self => $_[1], method => $_[3], } } }
    | exp '.' BAREWORD '(' exp ')'  %prec P003
        { $_[0]->{out}= { method_call => { self => $_[1], method => $_[3], param => $_[5], } } }
    | exp '.' BAREWORD exp   %prec P003
        { $_[0]->{out}= { method_call => { self => $_[1], method => $_[3], param => $_[4], } } }
        
    | stmt                
        { $_[0]->{out}= $_[1] }
    | stmt exp            
        { $_[0]->{out}= [ $_[1], $_[2] ] }
    | exp ';' stmt        
        { $_[0]->{out}= [ $_[1], $_[3] ] }
!,
    );
    # print "created operator table\n";
}

sub add_rule {
    # print "add operator\n";
    my $self = shift;
    my %opt = @_;
    # print "Operator add: @{[ %opt ]} \n";

    delete $opt{rule};
    $operator->add_op( \%opt );
    
    #push @subroutine_names, $opt{name};
}

use Pugs::Grammar::Infix;
use Pugs::Grammar::Prefix;
use Pugs::Grammar::Postfix;
use Pugs::Grammar::Circumfix;
use Pugs::Grammar::Postcircumfix;

sub recompile {
    my $class = shift;

    # tokenizer
    %hash = (
        %Pugs::Grammar::Infix::hash,
        %Pugs::Grammar::Prefix::hash,
        %Pugs::Grammar::Postfix::hash,
        %Pugs::Grammar::Circumfix::hash,
        %Pugs::Grammar::Postcircumfix::hash,
    );
    $class->SUPER::recompile;

    # operator-precedence
    my $g = $operator->emit_yapp;
    #print $g;
    my $p = $operator->emit_grammar_perl5;

    # create a local variable '$out' inside the parser
    # $p =~ s/my\(\$self\)=/my \$out; my\(\$self\)=/;

    #print $p;
    eval $p;
    die "$@\n" if $@;
}

BEGIN {
    #~ __PACKAGE__->add_rule( 
        #~ # tokenizer defined in Term.pm
        #~ name => 'CALL',
        #~ name2 => ')',
        #~ assoc => 'non',
        #~ precedence => 'tighter',
        #~ other => '*',
    #~ );

    __PACKAGE__->recompile;
}

1;
