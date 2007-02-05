# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::EmitPerl5; sub new { shift; bless { @_ }, "KindaPerl6::Visitor::EmitPerl5" } sub visit { my $self = shift; my $List__ = \@_; my $node; do {  $node = $List__->[0]; [$node] }; $node->emit_perl5() }
;
package Module; sub new { shift; bless { @_ }, "Module" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('{ package ' . ($self->{name} . (';' . (Main::newline() . ($self->{body}->emit_perl5() . (' }' . Main::newline())))))) }
;
package CompUnit; sub new { shift; bless { @_ }, "CompUnit" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub attributes { @_ == 1 ? ( $_[0]->{attributes} ) : ( $_[0]->{attributes} = $_[1] ) }; sub methods { @_ == 1 ? ( $_[0]->{methods} ) : ( $_[0]->{methods} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('{ package ' . ($self->{name} . ('; ' . ('sub new { shift; bless { @_ }, "' . ($self->{name} . ('" }' . (' ' . ($self->{body}->emit_perl5() . (' }' . Main::newline()))))))))) }
;
package Val::Int; sub new { shift; bless { @_ }, "Val::Int" } sub int { @_ == 1 ? ( $_[0]->{int} ) : ( $_[0]->{int} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('( bless \\( do{ my $v = ' . ($self->{int} . ' } ), \'Type_Constant_Int\' )')) }
;
package Val::Bit; sub new { shift; bless { @_ }, "Val::Bit" } sub bit { @_ == 1 ? ( $_[0]->{bit} ) : ( $_[0]->{bit} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('( bless \\( do{ my $v = ' . ($self->{bit} . ' } ), \'Type_Constant_Bit\' )')) }
;
package Val::Num; sub new { shift; bless { @_ }, "Val::Num" } sub num { @_ == 1 ? ( $_[0]->{num} ) : ( $_[0]->{num} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; $self->{num} }
;
package Val::Buf; sub new { shift; bless { @_ }, "Val::Buf" } sub buf { @_ == 1 ? ( $_[0]->{buf} ) : ( $_[0]->{buf} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('( bless \\( do{ my $v = ' . ('\'' . ($self->{buf} . ('\'' . ' } ), \'Type_Constant_Buf\' )')))) }
;
package Val::Undef; sub new { shift; bless { @_ }, "Val::Undef" } sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; '$GLOBAL::undef' }
;
package Val::Object; sub new { shift; bless { @_ }, "Val::Object" } sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) }; sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('bless(' . (Main::perl($self->{fields}, ) . (', ' . (Main::perl($self->{class}, ) . ')')))) }
;
package Lit::Seq; sub new { shift; bless { @_ }, "Lit::Seq" } sub seq { @_ == 1 ? ( $_[0]->{seq} ) : ( $_[0]->{seq} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('(' . (Main::join([ map { $_->emit_perl5() } @{ $self->{seq} } ], ', ') . ')')) }
;
package Lit::Array; sub new { shift; bless { @_ }, "Lit::Array" } sub array { @_ == 1 ? ( $_[0]->{array} ) : ( $_[0]->{array} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('[' . (Main::join([ map { $_->emit_perl5() } @{ $self->{array} } ], ', ') . ']')) }
;
package Lit::Hash; sub new { shift; bless { @_ }, "Lit::Hash" } sub hash { @_ == 1 ? ( $_[0]->{hash} ) : ( $_[0]->{hash} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $fields = $self->{hash}; my  $str = ''; do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit_perl5() . (' => ' . ($field->[1]->emit_perl5() . ',')))) } }; ('{ ' . ($str . ' }')) }
;
package Lit::Code; sub new { shift; bless { @_ }, "Lit::Code" } sub pad { @_ == 1 ? ( $_[0]->{pad} ) : ( $_[0]->{pad} = $_[1] ) }; sub state { @_ == 1 ? ( $_[0]->{state} ) : ( $_[0]->{state} = $_[1] ) }; sub sig { @_ == 1 ? ( $_[0]->{sig} ) : ( $_[0]->{sig} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $s; do { for my $name ( @{$self->{pad}->variable_names()} ) { my  $decl = Decl->new( 'decl' => 'my','type' => '','var' => Var->new( 'sigil' => '','twigil' => '','name' => $name, ), );$s = ($s . ($name->emit_perl5() . '; ')) } }; return(($s . Main::join([ map { $_->emit_perl5() } @{ $self->{body} } ], '; '))) }
;
package Lit::Object; sub new { shift; bless { @_ }, "Lit::Object" } sub class { @_ == 1 ? ( $_[0]->{class} ) : ( $_[0]->{class} = $_[1] ) }; sub fields { @_ == 1 ? ( $_[0]->{fields} ) : ( $_[0]->{fields} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $fields = $self->{fields}; my  $str = ''; do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit_perl5() . (' => ' . ($field->[1]->emit_perl5() . ',')))) } }; ($self->{class} . ('->new( ' . ($str . ' )'))) }
;
package Index; sub new { shift; bless { @_ }, "Index" } sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) }; sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{obj}->emit_perl5() . ('->INDEX(' . ($self->{index}->emit_perl5() . ')'))) }
;
package Lookup; sub new { shift; bless { @_ }, "Lookup" } sub obj { @_ == 1 ? ( $_[0]->{obj} ) : ( $_[0]->{obj} = $_[1] ) }; sub index { @_ == 1 ? ( $_[0]->{index} ) : ( $_[0]->{index} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{obj}->emit_perl5() . ('->LOOKUP(' . ($self->{index}->emit_perl5() . ')'))) }
;
package Assign; sub new { shift; bless { @_ }, "Assign" } sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ($self->{parameters}->emit_perl5() . ('->STORE(' . ($self->{arguments}->emit_perl5() . ')'))) }
;
package Var; sub new { shift; bless { @_ }, "Var" } sub sigil { @_ == 1 ? ( $_[0]->{sigil} ) : ( $_[0]->{sigil} = $_[1] ) }; sub twigil { @_ == 1 ? ( $_[0]->{twigil} ) : ( $_[0]->{twigil} = $_[1] ) }; sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $table = { '$' => '$','@' => '$List_','%' => '$Hash_','&' => '$Code_', }; do { if (($self->{twigil} eq '.')) { return(('$self->{' . ($self->{name} . '}'))) } else {  } }; do { if (($self->{name} eq '/')) { return(($table->{$self->{sigil}} . 'MATCH')) } else {  } }; return(Main::mangle_name($self->{sigil}, $self->{twigil}, $self->{name})) }
;
package Bind; sub new { shift; bless { @_ }, "Bind" } sub parameters { @_ == 1 ? ( $_[0]->{parameters} ) : ( $_[0]->{parameters} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; do { if (Main::isa($self->{parameters}, 'Lit::Array')) { my  $a = $self->{parameters}->array();my  $str = 'do { ';my  $i = 0;do { for my $var ( @{$a} ) { my  $bind = Bind->new( 'parameters' => $var,'arguments' => Index->new( 'obj' => $self->{arguments},'index' => Val::Int->new( 'int' => $i, ), ), );$str = ($str . (' ' . ($bind->emit_perl5() . '; ')));$i = ($i + 1) } };return(($str . ($self->{parameters}->emit_perl5() . ' }'))) } else {  } }; do { if (Main::isa($self->{parameters}, 'Lit::Hash')) { my  $a = $self->{parameters}->hash();my  $b = $self->{arguments}->hash();my  $str = 'do { ';my  $i = 0;my  $arg;do { for my $var ( @{$a} ) { $arg = Val::Undef->new(  );do { for my $var2 ( @{$b} ) { do { if (($var2->[0]->buf() eq $var->[0]->buf())) { $arg = $var2->[1] } else {  } } } };my  $bind = Bind->new( 'parameters' => $var->[1],'arguments' => $arg, );$str = ($str . (' ' . ($bind->emit_perl5() . '; ')));$i = ($i + 1) } };return(($str . ($self->{parameters}->emit_perl5() . ' }'))) } else {  } }; do { if (Main::isa($self->{parameters}, 'Lit::Object')) { my  $class = $self->{parameters}->class();my  $a = $self->{parameters}->fields();my  $b = $self->{arguments};my  $str = 'do { ';my  $i = 0;my  $arg;do { for my $var ( @{$a} ) { my  $bind = Bind->new( 'parameters' => $var->[1],'arguments' => Call->new( 'invocant' => $b,'method' => $var->[0]->buf(),'arguments' => [],'hyper' => 0, ), );$str = ($str . (' ' . ($bind->emit_perl5() . '; ')));$i = ($i + 1) } };return(($str . ($self->{parameters}->emit_perl5() . ' }'))) } else {  } }; ($self->{parameters}->emit_perl5() . (' = ' . $self->{arguments}->emit_perl5())) }
;
package Proto; sub new { shift; bless { @_ }, "Proto" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ("" . $self->{name}) }
;
package Call; sub new { shift; bless { @_ }, "Call" } sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) }; sub hyper { @_ == 1 ? ( $_[0]->{hyper} ) : ( $_[0]->{hyper} = $_[1] ) }; sub method { @_ == 1 ? ( $_[0]->{method} ) : ( $_[0]->{method} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $invocant = $self->{invocant}->emit_perl5(); do { if (($invocant eq 'self')) { $invocant = '$self' } else {  } }; do { if ((($self->{method} eq 'perl') || (($self->{method} eq 'yaml') || (($self->{method} eq 'say') || (($self->{method} eq 'join') || (($self->{method} eq 'chars') || ($self->{method} eq 'isa'))))))) { do { if ($self->{hyper}) { return(('[ map { Main::' . ($self->{method} . ('( $_, ' . (', ' . (Main::join([ map { $_->emit_perl5() } @{ $self->{arguments} } ], ', ') . (')' . (' } @{ ' . ($invocant . ' } ]'))))))))) } else { return(('Main::' . ($self->{method} . ('(' . ($invocant . (', ' . (Main::join([ map { $_->emit_perl5() } @{ $self->{arguments} } ], ', ') . ')'))))))) } } } else {  } }; my  $meth = $self->{method}; do { if (($meth eq 'postcircumfix:<( )>')) { $meth = '' } else {  } }; my  $call = ('->' . ($meth . ('(' . (Main::join([ map { $_->emit_perl5() } @{ $self->{arguments} } ], ', ') . ')')))); do { if ($self->{hyper}) { ('[ map { $_' . ($call . (' } @{ ' . ($invocant . ' } ]')))) } else { ($invocant . $call) } } }
;
package Apply; sub new { shift; bless { @_ }, "Apply" } sub code { @_ == 1 ? ( $_[0]->{code} ) : ( $_[0]->{code} = $_[1] ) }; sub arguments { @_ == 1 ? ( $_[0]->{arguments} ) : ( $_[0]->{arguments} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; return(('(' . ($self->{code}->emit_perl5() . (')->(' . (Main::join([ map { $_->emit_perl5() } @{ $self->{arguments} } ], ', ') . ')'))))) }
;
package Return; sub new { shift; bless { @_ }, "Return" } sub result { @_ == 1 ? ( $_[0]->{result} ) : ( $_[0]->{result} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; return(('return(' . ($self->{result}->emit_perl5() . ')'))) }
;
package If; sub new { shift; bless { @_ }, "If" } sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub otherwise { @_ == 1 ? ( $_[0]->{otherwise} ) : ( $_[0]->{otherwise} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('do { if (' . ($self->{cond}->emit_perl5() . (') { ' . ($self->{body}->emit_perl5() . (' } ' . (($self->{otherwise} ? (' else { ' . ($self->{otherwise}->emit_perl5() . ' }')) : '') . ' }')))))) }
;
package For; sub new { shift; bless { @_ }, "For" } sub cond { @_ == 1 ? ( $_[0]->{cond} ) : ( $_[0]->{cond} = $_[1] ) }; sub body { @_ == 1 ? ( $_[0]->{body} ) : ( $_[0]->{body} = $_[1] ) }; sub topic { @_ == 1 ? ( $_[0]->{topic} ) : ( $_[0]->{topic} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $cond = $self->{cond}; do { if ((Main::isa($cond, 'Var') && ($cond->sigil() eq '@'))) { $cond = Apply->new( 'code' => 'prefix:<@>','arguments' => [$cond], ) } else {  } }; ('do { for my ' . ($self->{topic}->emit_perl5() . (' ( ' . ($cond->emit_perl5() . (' ) { ' . ($self->{body}->emit_perl5() . ' } }')))))) }
;
package Decl; sub new { shift; bless { @_ }, "Decl" } sub decl { @_ == 1 ? ( $_[0]->{decl} ) : ( $_[0]->{decl} = $_[1] ) }; sub type { @_ == 1 ? ( $_[0]->{type} ) : ( $_[0]->{type} = $_[1] ) }; sub var { @_ == 1 ? ( $_[0]->{var} ) : ( $_[0]->{var} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $decl = $self->{decl}; my  $name = $self->{var}->name(); do { if (($decl eq 'has')) { return(('sub ' . ($name . (' { ' . ('@_ == 1 ' . ('? ( $_[0]->{' . ($name . ('} ) ' . (': ( $_[0]->{' . ($name . ('} = $_[1] ) ' . '}'))))))))))) } else {  } }; do { if (($decl eq 'our')) { my  $s;$s = ('use vars \'' . ($self->{var}->emit_perl5() . '\'; '));do { if (($self->{var}->sigil() eq '$')) { return(($s . ($self->{var}->emit_perl5() . ' = bless \\( do{ my $v = $GLOBAL::undef } ), \'Type_Scalar\' '))) } else {  } };do { if (($self->{var}->sigil() eq '%')) { return(($s . ($self->{var}->emit_perl5() . ' = bless { }, \'Type_Hash\' '))) } else {  } };do { if (($self->{var}->sigil() eq '@')) { return(($s . ($self->{var}->emit_perl5() . ' = bless [ ], \'Type_Array\' '))) } else {  } };return(($s . ($self->{var}->emit_perl5() . ' '))) } else {  } }; do { if (($self->{var}->sigil() eq '$')) { return(($self->{decl} . (' ' . ($self->{type} . (' ' . ($self->{var}->emit_perl5() . ' = bless \\( do{ my $v = $GLOBAL::undef } ), \'Type_Scalar\'')))))) } else {  } }; do { if (($self->{var}->sigil() eq '%')) { return(($self->{decl} . (' ' . ($self->{type} . (' ' . ($self->{var}->emit_perl5() . ' = bless { }, \'Type_Hash\'')))))) } else {  } }; do { if (($self->{var}->sigil() eq '@')) { return(($self->{decl} . (' ' . ($self->{type} . (' ' . ($self->{var}->emit_perl5() . ' = bless [ ], \'Type_Array\'')))))) } else {  } }; return(($self->{decl} . (' ' . ($self->{type} . (' ' . $self->{var}->emit_perl5()))))) }
;
package Sig; sub new { shift; bless { @_ }, "Sig" } sub invocant { @_ == 1 ? ( $_[0]->{invocant} ) : ( $_[0]->{invocant} = $_[1] ) }; sub positional { @_ == 1 ? ( $_[0]->{positional} ) : ( $_[0]->{positional} = $_[1] ) }; sub named { @_ == 1 ? ( $_[0]->{named} ) : ( $_[0]->{named} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ' print \'Signature - TODO\'; die \'Signature - TODO\'; ' }; sub invocant { my $self = shift; my $List__ = \@_; do { [] }; $self->{invocant} }; sub positional { my $self = shift; my $List__ = \@_; do { [] }; $self->{positional} }
;
package Method; sub new { shift; bless { @_ }, "Method" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $sig = $self->{block}->sig(); my  $invocant = $sig->invocant(); my  $pos = $sig->positional(); my  $str = 'my $List__ = \@_; '; my  $pos = $sig->positional(); do { for my $field ( @{$pos} ) { $str = ($str . ('my ' . ($field->emit_perl5() . '; '))) } }; my  $bind = Bind->new( 'parameters' => Lit::Array->new( 'array' => $sig->positional(), ),'arguments' => Var->new( 'sigil' => '@','twigil' => '','name' => '_', ), ); $str = ($str . ($bind->emit_perl5() . '; ')); ('sub ' . ($self->{name} . (' { ' . ('my ' . ($invocant->emit_perl5() . (' = shift; ' . ($str . ($self->{block}->emit_perl5() . ' }')))))))) }
;
package Sub; sub new { shift; bless { @_ }, "Sub" } sub name { @_ == 1 ? ( $_[0]->{name} ) : ( $_[0]->{name} = $_[1] ) }; sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; my  $sig = $self->{block}->sig(); my  $pos = $sig->positional(); my  $str = 'my $List__ = \@_; '; my  $pos = $sig->positional(); do { if (@{$pos}) { do { for my $field ( @{$pos} ) { $str = ($str . ('my ' . ($field->emit_perl5() . '; '))) } };my  $bind = Bind->new( 'parameters' => Lit::Array->new( 'array' => $sig->positional(), ),'arguments' => Var->new( 'sigil' => '@','twigil' => '','name' => '_', ), );$str = ($str . ($bind->emit_perl5() . '; ')) } else {  } }; ('sub ' . ($self->{name} . (' { ' . ($str . ($self->{block}->emit_perl5() . ' }'))))) }
;
package Do; sub new { shift; bless { @_ }, "Do" } sub block { @_ == 1 ? ( $_[0]->{block} ) : ( $_[0]->{block} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('do { ' . ($self->{block}->emit_perl5() . ' }')) }
;
package Use; sub new { shift; bless { @_ }, "Use" } sub mod { @_ == 1 ? ( $_[0]->{mod} ) : ( $_[0]->{mod} = $_[1] ) }; sub emit_perl5 { my $self = shift; my $List__ = \@_; do { [] }; ('use ' . $self->{mod}) }
;
1;
