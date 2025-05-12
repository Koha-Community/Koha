#!/usr/bin/env perl

use Modern::Perl;
use Test::More;
use Test::NoWarnings;
use Pod::Checker;
use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new;
my @files     = $dev_files->ls_perl_files;

plan tests => scalar @files + 1;

for my $file (@files) {
    my $checker = Pod::Checker->new();
    $checker->parse_from_file( $file, \*STDERR );
    my $num_errors   = $checker->num_errors;
    my $num_warnings = $checker->num_warnings;
    if ( $checker->num_errors > 0 ) {
        fail("Found pod errors for $file");
    } elsif ( $checker->num_errors == -1 ) {
        pass("Skip pod checker for $file - no pod found");
    } elsif ( $checker->num_warnings ) {
        fail("Found pod warnings for $file");
    } else {
        pass("pod for $file");
    }
}
