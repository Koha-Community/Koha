#!/usr/bin/env perl

=head1 NAME

icondirectories.t - test to ensure that the two directories of icons
in the staff and opac interface are identical.

=head1 DESCRIPTION

Tere are two directories of icons for media types, one for the opac
and one for the staff interface. They need to be identical. This
ensures that they are.

=cut

use strict;
use warnings;

use lib qw( .. );

use Data::Dumper;
use File::Find;
use Test::More tests => 3;

my $opac_icon_directory  = 'koha-tmpl/opac-tmpl/prog/itemtypeimg';
my $staff_icon_directory = 'koha-tmpl/intranet-tmpl/prog/img/itemtypeimg';

ok( -d $opac_icon_directory, "opac_icon_directory: $opac_icon_directory exists" );
ok( -d $staff_icon_directory, "staff_icon_directory: $staff_icon_directory exists" );

my $opac_icons; # hashref of filenames to sizes
sub opac_wanted {
    my $file = $File::Find::name;
    $file =~ s/^$opac_icon_directory//;
    $opac_icons->{ $file } = -s $_;
}

find( \&opac_wanted, $opac_icon_directory );

my $staff_icons; # hashref of filenames to sizes
sub staff_wanted {
    my $file = $File::Find::name;
    $file =~ s/^$staff_icon_directory//;
    $staff_icons->{ $file } = -s $_;
}
find( \&staff_wanted, $staff_icon_directory );

is_deeply( $opac_icons, $staff_icons )
  or diag( Data::Dumper->Dump( [ $opac_icons ], [ 'opac_icons' ] ) );














