#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;
use Test::NoWarnings;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new( { context => 'all' } );
my @files;
push @files, $dev_files->ls_perl_files;
push @files, $dev_files->ls_tt_files;
push @files, $dev_files->ls_js_files;
push @files, $dev_files->ls_yml_files;
push @files, $dev_files->ls_css_files;

plan tests => scalar @files + 1;

for my $file (@files) {
    if ( -z $file ) {

        # File is empty
        ok(1);
        next;
    }
    open my $fh, '<', $file or die "Can't open file ($file): $!";
    seek $fh, -1, 2 or die "Can't seek ($file): $!";
    read $fh, my $char, 1;
    close $fh;
    is( $char, "\n", "$file should end with a new line" );
}
