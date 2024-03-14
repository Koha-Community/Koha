#!/usr/bin/perl

# This file is part of Koha.
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
use Test::More;

use File::Spec;
use File::Find;

my @files;
sub wanted {
    my $name = $File::Find::name;
    push @files, $name
      if $name =~ m{^\./(
           acqui
          |admin
          |authorities
          |basket
          |catalogue
          |cataloguing
          |circ
          |clubs
          |course_reserves
          |labels
          |members
          |patroncards
          |pos
          |reports
          |reserve
          |reviews
          |rotating_collections
          |serials
          |services
          |suggestion
          |svc
          |tags
          |tools
          |virtualshelves
        )}xms
      && $name =~ m{\.(pl)$}
      && -f $name;
}

find({ wanted => \&wanted, no_chdir => 1 }, File::Spec->curdir());

my @missing_auth_check;
FILE: foreach my $name (@files) {
    open( FILE, $name ) || die "cannot open file $name $!";
    while ( my $line = <FILE> ) {
        for my $routine ( qw( get_template_and_user check_cookie_auth checkauth check_api_auth C4::Service->init ) ) {
            next FILE if $line =~ m|^[^#]*$routine|;
        }
    }
    push @missing_auth_check, $name;
}
is( scalar @missing_auth_check, 0 ) or diag "No auth check in the following files:\n" . join "\n", @missing_auth_check;
done_testing;
