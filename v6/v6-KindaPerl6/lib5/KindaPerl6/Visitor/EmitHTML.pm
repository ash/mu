# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::EmitHTML; sub new { shift; bless { @_ }, "KindaPerl6::Visitor::EmitHTML" } sub visit { my $self = shift; my $List__ = \@_; my $node; do {  $node = $List__->[0]; [$node] }; (html_header() . ($node->emit_html() . '</body></html>')) }; sub css { my $self = shift; my $List__ = \@_; do { [] }; my  $nl = Main::newline(); return(('<style type="text/css">' . ($nl . ('.keyword { text-weight: bold; color: red; }' . ($nl . ('.builtin { color: red; }' . ($nl . ('.buffer { color: blue; }' . ($nl . ('.comp_unit { color: #555500; }' . ($nl . ('</style>' . $nl)))))))))))) }; sub html_header { my $self = shift; my $List__ = \@_; do { [] }; my  $nl = Main::newline(); return(('<html>' . ($nl . ('<head>' . ($nl . ('<title>Auto-Generated P6 Code</title>' . ($nl . (css() . ('</head>' . ($nl . ('<body>' . $nl))))))))))) }
;
package CompUnit; sub new { shift; bless { @_ }, "CompUnit" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('{ <span class="keyword">module</span> ' . ($self->{name} . (';<br />' . (Main::newline() . ($self->{body}->emit_html() . ' }</span><br />'))))) }
;
package Val::Int; sub new { shift; bless { @_ }, "Val::Int" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('<span class="integer">' . ($self->{int} . '</span>')) }
;
package Val::Bit; sub new { shift; bless { @_ }, "Val::Bit" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; $self->{bit} }
;
package Val::Num; sub new { shift; bless { @_ }, "Val::Num" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; $self->{num} }
;
package Val::Buf; sub new { shift; bless { @_ }, "Val::Buf" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('<span class="buffer">' . ('\'' . ($self->{buf} . ('\'' . '</span>')))) }
;
package Val::Undef; sub new { shift; bless { @_ }, "Val::Undef" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; '<span class="keyword">undef</span>' }
;
package Val::Object; sub new { shift; bless { @_ }, "Val::Object" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('::' . (Main::perl($self->{class}, ) . ('(' . (Main::perl($self->{fields}, ) . ')')))) }
;
package Native::Buf; sub new { shift; bless { @_ }, "Native::Buf" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('\'' . ($self->{buf} . '\'')) }
;
package Lit::Seq; sub new { shift; bless { @_ }, "Lit::Seq" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('(' . (Main::join([ map { $_->emit_html() } @{ $self->{seq} } ], ', ') . ')')) }
;
package Lit::Array; sub new { shift; bless { @_ }, "Lit::Array" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('[' . (Main::join([ map { $_->emit_html() } @{ $self->{array} } ], ', ') . ']')) }
;
package Lit::Hash; sub new { shift; bless { @_ }, "Lit::Hash" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $fields = $self->{hash}; my  $str = ''; do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit_html() . (' <span class="operator>=&gt;</span> ' . ($field->[1]->emit_html() . ',')))) } }; ('{ ' . ($str . ' }')) }
;
package Lit::Code; sub new { shift; bless { @_ }, "Lit::Code" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $s; do { for my $name ( @{$self->{pad}->variable_names()} ) { my  $decl = Decl->new( 'decl' => 'my','type' => '','var' => Var->new( 'sigil' => '','twigil' => '','name' => $name, ), );$s = ($s . ($name->emit_html() . '; ')) } }; return(($s . Main::join([ map { $_->emit_html() } @{ $self->{body} } ], '; '))) }
;
package Lit::Object; sub new { shift; bless { @_ }, "Lit::Object" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $fields = $self->{fields}; my  $str = ''; do { for my $field ( @{$fields} ) { $str = ($str . ($field->[0]->emit_html() . (' => ' . ($field->[1]->emit_html() . ',')))) } }; ($self->{class} . ('.new( ' . ($str . ' )'))) }
;
package Index; sub new { shift; bless { @_ }, "Index" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ($self->{obj}->emit_html() . ('[' . ($self->{index}->emit_html() . ']'))) }
;
package Lookup; sub new { shift; bless { @_ }, "Lookup" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ($self->{obj}->emit_html() . ('{' . ($self->{index}->emit_html() . '}'))) }
;
package Assign; sub new { shift; bless { @_ }, "Assign" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ($self->{parameters}->emit_html() . (' <span class="op">=</span> ' . ($self->{arguments}->emit_html() . ''))) }
;
package Var; sub new { shift; bless { @_ }, "Var" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $table = { '$' => '$','@' => '$List_','%' => '$Hash_','&' => '$Code_', }; do { if (($self->{twigil} eq '.')) { return(('$self->{' . ($self->{name} . '}'))) } else {  } }; do { if (($self->{name} eq '/')) { return(($table->{$self->{sigil}} . 'MATCH')) } else {  } }; return(Main::mangle_name($self->{sigil}, $self->{twigil}, $self->{name})) }
;
package Bind; sub new { shift; bless { @_ }, "Bind" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ($self->{parameters}->emit_html() . (' <span class="operator>:=</span> ' . ($self->{arguments}->emit_html() . ''))) }
;
package Proto; sub new { shift; bless { @_ }, "Proto" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ("" . $self->{name}) }
;
package Call; sub new { shift; bless { @_ }, "Call" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $invocant; do { if (Main::isa($self->{invocant}, 'Str')) { $invocant = ('$::Class_' . $self->{invocant}) } else { do { if (Main::isa($self->{invocant}, 'Val::Buf')) { $invocant = ('$::Class_' . $self->{invocant}->buf()) } else { $invocant = $self->{invocant}->emit_html() } } } }; do { if (($invocant eq 'self')) { $invocant = '$self' } else {  } }; do { if ((($self->{method} eq 'perl') || (($self->{method} eq 'yaml') || (($self->{method} eq 'say') || (($self->{method} eq 'join') || (($self->{method} eq 'chars') || ($self->{method} eq 'isa'))))))) { do { if ($self->{hyper}) { return(('[ <span class="keyword">map</span> { Main::' . ($self->{method} . ('( $_, ' . (', ' . (Main::join([ map { $_->emit_html() } @{ $self->{arguments} } ], ', ') . (')' . (' } @{ ' . ($invocant . ' } ]'))))))))) } else { return(('Main::' . ($self->{method} . ('(' . ($invocant . (', ' . (Main::join([ map { $_->emit_html() } @{ $self->{arguments} } ], ', ') . ')'))))))) } } } else {  } }; my  $meth = $self->{method}; do { if (($meth eq 'postcircumfix:<( )>')) { $meth = '' } else {  } }; my  $call = Main::join([ map { $_->emit_html() } @{ $self->{arguments} } ], ', '); do { if ($self->{hyper}) { ('[ <span class="map">map</span> { $_' . ('->' . ($meth . ('(' . ($call . (') } @{ ' . ($invocant . ' } ]'))))))) } else { ('(' . ($invocant . ('->FETCH->{_role_methods}{' . ($meth . ('}' . (' ?? ' . ($invocant . ('->FETCH->{_role_methods}{' . ($meth . ('}{code}' . ('(' . ($invocant . ('->FETCH, ' . ($call . (')' . (' !! ' . ($invocant . ('->FETCH->' . ($meth . ('(' . ($call . (')' . ')')))))))))))))))))))))) } } }
;
package Apply; sub new { shift; bless { @_ }, "Apply" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; return(('(' . ($self->{code}->emit_html() . (')(' . (Main::join([ map { $_->emit_html() } @{ $self->{arguments} } ], ', ') . ')'))))) }
;
package Return; sub new { shift; bless { @_ }, "Return" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; return(('<span class="keyword">return (' . ($self->{result}->emit_html() . (')<br />' . Main::newline())))) }
;
package If; sub new { shift; bless { @_ }, "If" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('<span class="keyword">do</span> { <span class="keyword">if</span> ( ${' . ($self->{cond}->emit_html() . ('->FETCH} ) { ' . ($self->{body}->emit_html() . (' } ' . (($self->{otherwise} ? (' else { ' . ($self->{otherwise}->emit_html() . ' }')) : '') . ' }')))))) }
;
package For; sub new { shift; bless { @_ }, "For" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $cond = $self->{cond}; do { if ((Main::isa($cond, 'Var') && ($cond->sigil() eq '@'))) { $cond = Apply->new( 'code' => 'prefix:<@>','arguments' => [$cond], ) } else {  } }; ('<span class="keyword">do</span> { <span class="keyword">for my</span> ' . ($self->{topic}->emit_html() . (' ( ' . ($cond->emit_html() . (' ) { ' . ($self->{body}->emit_html() . ' } }')))))) }
;
package Decl; sub new { shift; bless { @_ }, "Decl" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; return(($self->{decl} . (' ' . ($self->{type} . (' ' . $self->{var}->emit_html()))))) }
;
package Sig; sub new { shift; bless { @_ }, "Sig" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ' print \'Signature - TODO\'; die \'Signature - TODO\'; ' }
;
package Method; sub new { shift; bless { @_ }, "Method" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $sig = $self->{block}->sig(); my  $invocant = $sig->invocant(); my  $pos = $sig->positional(); my  $str = 'my $List__ = \@_; '; my  $pos = $sig->positional(); do { for my $field ( @{$pos} ) { $str = ($str . ('my ' . ($field->emit_html() . '; '))) } }; my  $bind = Bind->new( 'parameters' => Lit::Array->new( 'array' => $sig->positional(), ),'arguments' => Var->new( 'sigil' => '@','twigil' => '','name' => '_', ), ); $str = ($str . ($bind->emit_html() . '; ')); ('<span class="keyword">sub</span> ' . ($self->{name} . (' { ' . ('<span class="keyword">my</span> ' . ($invocant->emit_html() . (' = <span class="builtin">shift</span>; ' . ('<br />' . (Main::newline() . ($str . ($self->{block}->emit_html() . ' }')))))))))) }
;
package Sub; sub new { shift; bless { @_ }, "Sub" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; my  $sig = $self->{block}->sig(); my  $pos = $sig->positional(); my  $str = 'my $List__ = \@_; '; my  $pos = $sig->positional(); do { if (@{$pos}) { do { for my $field ( @{$pos} ) { $str = ($str . ('my ' . ($field->emit_html() . '; '))) } };my  $bind = Bind->new( 'parameters' => Lit::Array->new( 'array' => $sig->positional(), ),'arguments' => Var->new( 'sigil' => '@','twigil' => '','name' => '_', ), );$str = ($str . ($bind->emit_html() . '; ')) } else {  } }; my  $code = ('sub { ' . ($str . ($self->{block}->emit_html() . ' }'))); do { if ($self->{name}) { return(('$Code_' . ($self->{name} . (' :=  ' . ($code . ''))))) } else {  } }; return($code) }
;
package Do; sub new { shift; bless { @_ }, "Do" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('<span class="keyword">do</span> { <br />' . (Main::newline() . ($self->{block}->emit_html() . ('}<br />' . Main::newline())))) }
;
package BEGIN; sub new { shift; bless { @_ }, "BEGIN" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('BEGIN { ' . ($self->{block}->emit_html() . ' }')) }
;
package Use; sub new { shift; bless { @_ }, "Use" } sub emit_html { my $self = shift; my $List__ = \@_; do { [] }; ('use ' . $self->{mod}) }
;
1;
