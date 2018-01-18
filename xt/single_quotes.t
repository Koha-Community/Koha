#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2013 Horowhenua Library Trust
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 1;
use File::Find;

my @themes;

# OPAC themes
my $opac_dir  = 'koha-tmpl/opac-tmpl';
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
for my $theme ( grep { not /^\.|lib|js|xslt/ } readdir($dh) ) {
    push @themes, "$opac_dir/$theme/en";
}
close $dh;

# STAFF themes
my $staff_dir = 'koha-tmpl/intranet-tmpl';
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
for my $theme ( grep { not /^\.|lib|js/ } readdir($dh) ) {
    push @themes, "$staff_dir/$theme/en";
}
close $dh;

my @files;
find(
    sub {
        open my $fh, $_ or die "Could not open $_: $!";
        my @lines = sort grep /\_\(\'/, <$fh>;
        push @files, { name => "$_", lines => \@lines } if @lines;
    },
    @themes
);

ok( !@files, "Files do not contain single quotes _(' " )
  or diag(
    "Files list: \n",
    join( "\n",
        map { $_->{name} . ': ' . join( ', ', @{ $_->{lines} } ) } @files )
  );
