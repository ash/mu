package Pugs::Emitter::Rule::Perl5::Ratchet;

# p6-rule perl5 emitter for ":ratchet" (non-backtracking)
# see: RuleInline.pl, RuleInline-more.pl for a program prototype

# XXX - cleanup unused nodes

use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Indent = 1;

our $direction = "+";  # XXX make lexical
our $sigspace = 0;
our $capture_count;
our $capture_to_array;

# XXX - reuse this sub in metasyntax()
sub call_subrule {
    my ( $subrule, $tab, @param ) = @_;
    $subrule = "\$grammar->" . $subrule unless $subrule =~ / :: | \. | -> /x;
    $subrule =~ s/\./->/;   # XXX - source filter
    return 
        "$tab     $subrule( \$s, { p => \$pos, args => {" . join(", ",@param) . "} }, \$_[3] )";
}

sub call_constant {
    my $const = $_[0];
    my $len = length( eval "'$const'" );
    $const = ( $_[0] eq $_ ? "chr(".ord($_).")" : $_[0] )
        for qw( \ ' );     # '
    return
    "$_[1] ( ( substr( \$s, \$pos, $len ) eq '$const' ) 
$_[1]     ? do { \$pos $direction= $len; 1 }
$_[1]     : 0
$_[1] )";
}

sub call_perl5 {
    my $const = $_[0];
    return
    "$_[1] ( ( substr( \$s, \$pos ) =~ m/^$const/s )  
$_[1]     ? do { \$pos $direction= length \$&; 1 }
$_[1]     : 0
$_[1] )";
}

sub emit {
    my ($grammar, $ast, $param) = @_;
    # runtime parameters: $grammar, $string, $state, $arg_list
    # rule parameters: see Runtime::Rule.pm
    local $sigspace = $param->{sigspace};   # XXX - $sigspace should be lexical
    local $capture_count = -1;
    local $capture_to_array = 0;
    return 
        "sub {\n" . 
        "  my \$grammar = \$_[0];\n" .
        "  my \$s = \$_[1];\n" .
        #"  my \$pos;\n" .
        #"  print \"match arg_list = \$_[1]\n\";\n" .
        #"  print \"match arg_list = \@{[\%{\$_[1]} ]}\n\" if defined \$_[1];\n" .
        #"  \$pos = 0 unless defined \$pos;   # TODO - .*? \$match \n" .
        #"  print \"match pos = \$pos\n\";\n" .
        "  my \$m;\n" .

        "  for my \$pos ( defined \$_[3]{p} ? \$_[3]{p} : ( 0 .. length( \$s ) - 1 ) ) {\n" .

        "    my \%index;\n" . 
        "    my \@match;\n" .
        "    my \%named;\n" .
        #"  my \$from = \$pos;\n" .
        "    my \$bool = 1;\n" .
        "    my \$capture;\n" .
        "    \$m = Pugs::Runtime::Match::Ratchet->new( { \n" .
        "      str => \\\$s, from => \\(0+\$pos), to => \\(\$pos), \n" .
        "      bool => \\\$bool, match => \\\@match, named => \\\%named, capture => \\\$capture, \n" .
        "    } );\n" .
        "    \$bool = 0 unless\n" .
        emit_rule( $ast, '   ' ) . ";\n" .

        "    last if \$m;\n" .
        "  }\n" .  # /for
        "  return \$m;\n" .
        "}\n";
}

sub emit_rule {
    my $n = $_[0];
    my $tab = $_[1] . '  ';
    die "unknown node: ", Dumper( $n )
        unless ref( $n ) eq 'HASH';
    #print "NODE ", Dumper($n);
    my ($k) = keys %$n;
    my $v = $$n{$k};
    #my ( $k, $v ) = each %$n;
    # XXX - use real references
    no strict 'refs';
    #print "NODE ", Dumper($k), ", ", Dumper($v);
    my $code = &$k( $v, $tab );
    return $code;
}

#rule nodes

sub non_capturing_group {
    return emit_rule( $_[0], $_[1] );
}        
sub quant {
    my $term = $_[0]->{'term'};
    my $quantifier = $_[0]->{quant};
    #print "QUANT: ",Dumper($_[0]);
    $quantifier = '' unless defined $quantifier;
    # TODO: fix grammar to not emit empty quantifier
    my $tab = ( $quantifier eq '' ) ? $_[1] : $_[1] . "  ";
    my $ws = metasyntax( '?ws', $tab );
    my $ws3 = ( $sigspace && $_[0]->{ws3} ne '' ) ? " &&\n$ws" : '';

    my $rul;
    {
        local $capture_to_array = ( $quantifier ne '' );
        $rul = emit_rule( $term, $tab );
    }

    $rul = "$ws &&\n$rul" if $sigspace && $_[0]->{ws1} ne '';
    $rul = "$rul &&\n$ws" if $sigspace && $_[0]->{ws2} ne '';
    #print $rul;
    return $rul 
        if $quantifier eq '';
    # *  +  ?
    # TODO: *? +? ??
    # TODO: *+ ++ ?+
    # TODO: quantifier + capture creates Array
    return 
        "$_[1] do { (\n$rul\n" .
        "$_[1] ||\n" .
        "$_[1]   1\n" .
        "$_[1] ) }$ws3"
        if $quantifier eq '?';
    return 
        "$_[1] do { while (\n$rul) {}; 1 }$ws3"
        if $quantifier eq '*';
    return
        "$_[1] do { \n" . 
        "$_[1] (\n$rul\n" .
        "$_[1] &&\n" .
        "$_[1]   do { while (\n$rul) {}; 1 }\n" .
        "$_[1] ) }$ws3"
        if $quantifier eq '+';
    die "quantifier not implemented: $quantifier";
}        
sub alt {
    my @s;
    # print 'Alt: ';
    my $count = $capture_count;
    my $max = -1;
    for ( @{$_[0]} ) { 
        $capture_count = $count;
        my $tmp = emit_rule( $_, $_[1].'  ' );
        # print ' ',$capture_count;
        $max = $capture_count 
            if $capture_count > $max;
        push @s, $tmp if $tmp;   
    }
    $capture_count = $max;
    # print " max = $capture_count\n";
    return 
        "$_[1] do {
$_[1]   my \$pos1 = \$pos;
$_[1]   do {
" . join( "\n$_[1]   } || do { \$pos = \$pos1;\n", @s ) . "
$_[1]   }
$_[1] }";
}        
sub concat {
    my @s;
    for ( @{$_[0]} ) { 
        my $tmp = emit_rule( $_, $_[1] );
        push @s, $tmp if $tmp;   
    }
    @s = reverse @s if $direction eq '-';
    return "$_[1] (\n" . join( "\n$_[1] &&\n", @s ) . "\n$_[1] )";
}        
sub code {
    return "$_[1] $_[0]\n";  
}        
sub dot {
    if ( $direction eq '+' ) {
        "$_[1] do { \$pos < length( \$s ) ? ++\$pos : 0 }"
    }
    else {
        "$_[1] do { \$pos >= 0 ? do{ --\$pos; 1 } : 0 }"
    }
}
sub variable {
    my $name = "$_[0]";
    my $value = undef;
    # XXX - eval $name doesn't look up in user lexical pad
    # XXX - what &xxx interpolate to?
    
    if ( $name =~ /^\$/ ) {
        # $^a, $^b
        if ( $name =~ /^ \$ \^ ([^\s]*) /x ) {
            my $index = ord($1)-ord('a');
            #print "Variable #$index\n";
            #return "$_[1] constant( \$_[7][$index] )\n";
            
            my $code = 
            "    ... sub { 
                #print \"Runtime Variable args[\", join(\",\",\@_) ,\"] \$_[7][$index]\\n\";
                return constant( \$_[7][$index] )->(\@_);
            }";
            $code =~ s/^/$_[1]/mg;
            return "$code\n";
        }
        else {
            $value = eval $name;
        }
    }
    
    $value = join('', eval $name) if $name =~ /^\@/;
    if ( $name =~ /^%/ ) {
        # XXX - runtime or compile-time interpolation?
        return "$_[1] ... hash( \\$name )\n" if $name =~ /::/;
        return "$_[1] ... hash( get_variable( '$name' ) )\n";
    }
    die "interpolation of $name not implemented"
        unless defined $value;

    return call_constant( $value, $_[1] );
}
sub special_char {
    my $char = substr($_[0],1);
    for ( qw( r n t e f w d s ) ) {
        return call_perl5(   "\\$_",  $_[1] ) if $char eq $_;
        return call_perl5( "[^\\$_]", $_[1] ) if $char eq uc($_);
    }
    $char = '\\\\' if $char eq '\\';
    return call_constant( $char, $_[1] );
}
sub match_variable {
    my $name = $_[0];
    my $num = substr($name,1);
    #print "var name: ", $num, "\n";
    my $code = 
    "    ... sub { 
        my \$m = Pugs::Runtime::Match::Ratchet->new( \$_[2] );
        return constant( \"\$m->[$num]\" )->(\@_);
    }";
    $code =~ s/^/$_[1]/mg;
    return "$code\n";
}
sub closure {
    my $code = $_[0]; 
    
    # XXX XXX XXX - source-filter - temporary hacks to translate p6 to p5
    # $()<name>
    $code =~ s/ ([^']) \$ \( \) < (.*?) > /$1 \$_[0]->[$2] /sgx;
    # $<name>
    $code =~ s/ ([^']) \$ < (.*?) > /$1 \$_[0]->{$2} /sgx;
    # $()
    $code =~ s/ ([^']) \$ \( \) /$1 \$_[0]->() /sgx;
    # $/
    $code =~ s/ ([^']) \$ \/ /$1 \$_[0] /sgx;
    #print "Code: $code\n";
    
    return 
        "$_[1] ( sub $code->( \$m ) || 1 )" 
        unless $code =~ /return/;
        
    return
        "$_[1] ( ( \$capture = sub $code->( \$m ) ) 
$_[1]   && return \$m )";
}
sub capturing_group {
    my $program = $_[0];

    $capture_count++;

    {
        local $capture_count = -1;
        local $capture_to_array = 0;
        $program = emit_rule( $program, $_[1].'      ' )
            if ref( $program );
    }

    return "$_[1] do{ 
$_[1]     my \$hash = do {
$_[1]       my \$bool = 1;
$_[1]       my \$from = \$pos;
$_[1]       my \@match;
$_[1]       my \%named;
$_[1]       my \$capture;
$_[1]       \$bool = 0 unless
" .             $program . ";
$_[1]       { str => \\\$s, from => \\\$from, match => \\\@match, named => \\\%named, bool => \\\$bool, to => \\(0+\$pos), capture => \\\$capture }
$_[1]     };
$_[1]     my \$bool = \${\$hash->{'bool'}};" .
        ( $capture_to_array 
        ? "
$_[1]     if ( \$bool ) {
$_[1]         push \@{ \$match[ $capture_count ] }, Pugs::Runtime::Match::Ratchet->new( \$hash );
$_[1]     }"
        : "
$_[1]     \$match[ $capture_count ] = Pugs::Runtime::Match::Ratchet->new( \$hash );"
        ) . "
$_[1]     \$bool;
$_[1] }";
}        
sub named_capture {
    my $name    = $_[0]{ident};
    my $program = $_[0]{rule};
    my $flat    = $_[0]{flat};
    $program = emit_rule( $program, $_[1].'        ' )
        if ref( $program );
    # TODO - repeated captures create an Array

    my($try_match, $gen_match, $post_match);
    if ( $flat ) {
        $try_match = <<"."
$_[1]     my \$bool = 1;
$_[1]     \$bool = 0 unless
.
.            $program . ";\n";
        $gen_match = "\$match[-1]";
	$post_match = "\$#match--;";
    } else {
        $try_match = <<"." ;
$_[1]     my \$hash = do {
$_[1]       my \$bool = 1;
$_[1]       my \$from = \$pos;
$_[1]       my \@match;
$_[1]       my \%named;
$_[1]       my \$capture;
$_[1]       \$bool = 0 unless
$program;
$_[1]       { str => \\\$s, from => \\\$from, match => \\\@match, named => \\\%named, bool => \\\$bool, to => \\(0+\$pos), capture => \\\$capture }
$_[1]     };
$_[1]     my \$bool = \${\$hash->{'bool'}};
.
        $gen_match = "Pugs::Runtime::Match::Ratchet->new( \$hash )";
	$post_match = "";
    }

    return "$_[1] do{ 
$try_match
$_[1]     if ( \$bool ) {
$_[1]       my \$match = $gen_match;" .
        ( $capture_to_array 
        ? "
$_[1]       push \@{\$named{'$name'}}, \$match;" 
        : "
$_[1]       \$named{'$name'} = \$match;"
        ) .
"
$_[1]     }
$_[1]     $post_match
$_[1]     \$bool;
$_[1] }";
}
sub before {
    my $program = $_[0]{rule};
    $program = emit_rule( $program, $_[1].'        ' )
        if ref( $program );
    return "$_[1] do{ 
$_[1]     my \$pos1 = \$pos;
$_[1]     do {
$_[1]       my \$pos = \$pos1;
$_[1]       my \$from = \$pos;
$_[1]       my \@match;
$_[1]       my \%named;
$_[1]       my \$capture;
$_[1]       \$bool = 0 unless
" .             $program . ";
$_[1]       \$bool;
$_[1]     };
$_[1] }";
}
sub after {
    local $direction = "-";
    my $program = $_[0]{rule};
    $program = emit_rule( $program, $_[1].'        ' )
        if ref( $program );
    return "$_[1] do{ 
$_[1]     my \$pos1 = \$pos;
$_[1]     do {
$_[1]       my \$pos = \$pos1 - 1;
$_[1]       my \$from = \$pos;
$_[1]       my \@match;
$_[1]       my \%named;
$_[1]       my \$capture;
$_[1]       \$bool = 0 unless
" .             $program . ";
$_[1]       \$bool;
$_[1]     };
$_[1] }";
}
sub colon {
    my $str = $_[0];
    return "$_[1] # : no-op\n"
        if $str eq ':';
    return "$_[1] ( \$pos >= length( \$s ) ) \n" 
        if $str eq '$';
    return "$_[1] ( \$pos == 0 ) \n" 
        if $str eq '^';
    die "'$str' not implemented";
}
sub constant {
    call_constant( @_ );
}

use vars qw( %char_class );
BEGIN {
    %char_class = map { $_ => 1 } qw( 
alpha
alnum
ascii
blank
cntrl
digit
graph
lower
print
punct
space
upper
word
xdigit
);
}

sub metasyntax {
    # <cmd>
    my $cmd = $_[0];   
    my $prefix = substr( $cmd, 0, 1 );
    if ( $prefix eq '@' ) {
        # XXX - wrap @array items - see end of Pugs::Grammar::Rule
        # TODO - param list
        return 
            "$_[1] do {\n" . 
            "$_[1]    my \$match;\n" . 
            "$_[1]    for my \$subrule ( $cmd ) {\n" . 
            "$_[1]        \$match = " . 
                call_subrule( '$subrule', '', () ) . ";\n" .
            "$_[1]        last if \$match;\n" . 
            "$_[1]    }\n" .
            "$_[1]    my \$bool = (!\$match != 1);\n" . 
            "$_[1]    \$pos = \$match->to if \$bool;\n" . 
            "$_[1]    \$bool;\n" . 
            "$_[1] }";
    }
    if ( $prefix eq '$' ) {
        if ( $cmd =~ /::/ ) {
            # call method in fully qualified $package::var
            # ...->match( $rule, $str, $grammar, $flags, $state )  
            # TODO - send $pos to subrule
            return 
                "$_[1]         do {\n" .
                "$_[1]           push \@match,\n" . 
                "$_[1]             $cmd->match( \$s, \$grammar, {p => \$pos}, undef );\n" .
                "$_[1]           \$pos = \$match[-1]->to;\n" .
                "$_[1]           !\$match[-1] != 1;\n" .
                "$_[1]         }"
        }
        # call method in lexical $var
        # TODO - send $pos to subrule
        return 
                "$_[1]         do {\n" .
                "$_[1]           my \$r = Pugs::Runtime::Rule::get_variable( '$cmd' );\n" . 
                "$_[1]           push \@match,\n" . 
                "$_[1]             \$r->match( \$s, \$grammar, {p => \$pos}, undef );\n" .
                "$_[1]           \$pos = \$match[-1]->to;\n" .
                "$_[1]           !\$match[-1] != 1;\n" .
                "$_[1]         }"
    }
    if ( $prefix eq q(') ) {   # single quoted literal ' 
        $cmd = substr( $cmd, 1, -1 );
        return call_constant( $cmd, $_[1] );
    }
    if ( $prefix eq q(") ) {   # interpolated literal "
        $cmd = substr( $cmd, 1, -1 );
        warn "<\"...\"> not implemented";
        return;
    }
    if ( $prefix =~ /[-+[]/ ) {   # character class 
	   if ( $prefix eq '-' ) {
	       $cmd = '[^' . substr($cmd, 2);
	   } 
       elsif ( $prefix eq '+' ) {
	       $cmd = substr($cmd, 2);
	   }
	   # XXX <[^a]> means [\^a] instead of [^a] in perl5re

	   return call_perl5($cmd, $_[1]);
    }
    if ( $prefix eq '?' ) {   # non_capturing_subrule / code assertion
        $cmd = substr( $cmd, 1 );
        if ( $cmd =~ /^{/ ) {
            warn "code assertion not implemented";
            return;
        }
        return
	    "$_[1] do { my \$match =\n" .
	    call_subrule( $cmd, $_[1] . "          " ) . ";\n" .
	    "$_[1]      my \$bool = (!\$match != 1);\n" .
	    "$_[1]      \$pos = \$match->to if \$bool;\n" .
	    "$_[1]      \$bool;\n" .
	    "$_[1] }";
    }
    if ( $prefix eq '!' ) {   # negated_subrule / code assertion 
        $cmd = substr( $cmd, 1 );
        if ( $cmd =~ /^{/ ) {
            warn "code assertion not implemented";
            return;
        }
        return 
            "$_[1] ... negate( '$_[0]', \n" .
            call_subrule( $_[0], $_[1]."  " ) .
            "$_[1] )\n";
    }
    if ( $cmd eq '.' ) {
            warn "<$cmd> not implemented";
            return;
    }
    if ( $prefix =~ /[_[:alnum:]]/ ) {  
        # "before" and "after" are handled in a separate rule
        if ( $cmd eq 'cut' ) {
            warn "<$cmd> not implemented";
            return;
        }
        if ( $cmd eq 'commit' ) {
            warn "<$cmd> not implemented";
            return;
        }
        if ( $cmd eq 'prior' ) {
            warn "<$cmd> not implemented";
            return;
        }
        if ( $cmd eq 'null' ) {
            warn "<$cmd> not implemented";
            return;
        }
        if ( exists $char_class{$cmd} ) {
            # XXX - inlined char classes are not inheritable, but this should be ok
            return
                "$_[1] ( ( substr( \$s, \$pos, 1 ) =~ /[[:$cmd:]]/ ) 
$_[1]     ? do { $direction$direction\$pos; 1 }
$_[1]     : 0
$_[1] )";
        }
        # capturing subrule
        # <subrule ( param, param ) >
        my ( $subrule, $param_list ) = split( /[\(\)]/, $cmd );
        $param_list = '' unless defined $param_list;
        my @param = split( ',', $param_list );
        # TODO - send $pos to subrule
        return named_capture(
            { ident => $subrule, 
              rule => 
                "$_[1]         do {\n" . 
                "$_[1]           push \@match,\n" . 
                    call_subrule( $subrule, $_[1]."        ", @param ) . ";\n" .
                "$_[1]           my \$bool = (!\$match[-1] != 1);\n" .
                "$_[1]           \$pos = \$match[-1]->to if \$bool;\n" .
                #"print !\$match[-1], ' ', Dumper \$match[-1];\n" .
                "$_[1]           \$bool;\n" .
                "$_[1]         }",
	      flat => 1
            }, 
            $_[1],    
        );
    }
    die "<$cmd> not implemented";
}

1;
