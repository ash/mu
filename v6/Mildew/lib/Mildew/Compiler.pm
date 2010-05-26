use v5.10;
use MooseX::Declare;
use AST;
use VAST;
BEGIN {
    for (<src/VAST/*.pm>) {
	require $_;
    }
}
class Mildew::Compiler {
    use AST::Helpers;
    has frontend  => (is=>'ro');
    has backend => (is=>'ro');
    method ast($code) {
        my $ast = $self->frontend->parse($code)->emit_m0ld;

        $ast;
    }
    method run($code) {
        $self->backend->run($self->ast($code));
    }
    method compile($code,$output) {
        $self->backend->compile($self->ast($code),$output);
    }
}
