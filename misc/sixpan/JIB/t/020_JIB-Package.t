use Test::More 'no_plan';
use Test::NoWarnings;
use strict;
use Path::Class;

BEGIN { chdir 't' if -d 't' };
BEGIN { use lib qw[../lib inc] };
BEGIN { require 'conf.pl' }
BEGIN { require 'pkg.pl' }

use JIB::Installation;
use JIB::Config;

my $Conf    = JIB::Config->new;
my $Class   = 'JIB::Package';
my @Acc     = sort qw[package file config meta];
my $Inst    = JIB::Installation->new( dir => $INSTALLATION_DIR );


### XXX config
my $Pkg     = $PKGS{'p5-Foo-Bar-1.2-cpan+KANE'};
my $File    = $Pkg->file;
my @Parse   = qw[prefix name version authority];

use_ok( $Class );

### XXX package->new now takes a jib file as argument
### need to fix tests for that

### create an object 
my $Obj;
{   $Obj = $Class->new( file => $File );
    ok( $Obj,                   "Object created" );
    isa_ok( $Obj,               $Class );
    
    my @can = sort $Obj->ls_accessors;
    ok( scalar(@can),           "   Object has accessors" );
    is_deeply( \@can, \@Acc,    "   Object can do what it should" );
    
    for my $method ( @can ) {
        ok( $Obj->$method,      "   '$method' returns value" );
    }        
}    

### test bogus assign to package
{   local $SIG{__WARN__} = sub {};
    ok( !$Obj->package( [] ),   "Bogus 'package' value not allowed" );
}

### test regexes
{   ### build a method => value map
    my $i;
    my %map = map { $Parse[$i++] => $_ } map { $Obj->$_ } @Parse;
 
    for my $method ( keys %map ) {
        can_ok( $Obj,           $method );
        
        my $rv = $Obj->$method;
        ok( $rv,                "   Returns '$rv'" );
        is( $rv, $map{$method}, "       As expected" );
    }
}
 
### installl the package
{   my $inst_pkg = $Obj->install( installation => $Inst );
    ok( $inst_pkg,              "Package installed" );
    isa_ok( $inst_pkg,          "JIB::Package::Installed" );
    ok( $Inst->is_installed( package => $Obj ),
                                "   Package installation registered" );
    
    
    ### XXX add more file tests
    for my $file ( @{ $inst_pkg->files } ) {
        ok( -e $file,           "   File '$file' exists" );
    }
    
    ### check for module
    ### XXX get this from config/object
    {   my $pm = file( 
                    $Inst->dir,
                    $Obj->package,
                    qw[lib Foo Bar.pm]
                );
                
        ok( -e $pm,             "   Module '$pm' exists" );
    
    }
    
    ### check for scripts
    ### XXX get this from config/object
    {   my $script = 'script.pl';
        my $conf   = $Obj->config;
        for my $dir ( $Inst->alternatives_dir, $conf->bin_dir,
                      $Inst->dir->subdir( $Obj->package )->subdir( 'bin' )
        ) {
            my $path = $dir->file( $script );
            ok( -d $dir,        "   Bin dir '$dir' exists" );
            ok( -e $path,       "       Script '$script' installed there" );
        }
    
    }
    
    ### XXX check for manpages
    {
        1;
    
    }


    ### install again
    {
        my $log = file('error_log');
        my $fh  = $log->openw;
        local $Log::Message::Simple::ERROR_FH = $fh;
        
        ok( $Obj->install( installation => $Inst ),           
                                "Second install returns true" );

        close $fh;
        like( scalar $log->slurp, qr/is already installed/,
                                '   Prior installation detected' );

        $log->remove;
    }
}    

### Uninstall tests
{   my $inst_pkg = $Inst->is_installed( package => $Obj );
    ok( $inst_pkg,              "Retrieved installed package" );
    isa_ok( $inst_pkg,          "JIB::Package::Installed" );
    ok( $inst_pkg->uninstall,   "   Package uninstalled" );

    ### XXX more file tests
    for my $file ( @{ $inst_pkg->files } ) {
        ok( !-e $file,          "       File '$file' no longer exists" );
    }    
}


# Local variables:
# c-indentation-style: bsd
# c-basic-offset: 4
# indent-tabs-mode: nil
# End:
# vim: expandtab shiftwidth=4:
