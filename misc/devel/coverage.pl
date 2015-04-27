#!/usr/bin/perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

coverage.pl

=head1 SYNOPSIS

You have to be in yout Koha/src directory
./misc/devel/coverage.pl

=head1 DESCRIPTION

This script make a cover on all files to see which modules are not tested yet

=cut

use Modern::Perl;
use C4::Context;
use Cwd;

#Die if you are not in your Koha src directory
my $KOHA_PATH = C4::Context->config("intranetdir");
die "ERROR : You are not in Koha src/ directory"
  unless $KOHA_PATH eq getcwd;

# Delete old coverage
system("cover -delete");

#Start the cover
system("PERL5OPT=-MDevel::Cover /usr/bin/prove -r t/");

#Create the HTML output
system("cover");
say("file://$KOHA_PATH/cover_db/coverage.html")
  unless !-e "$KOHA_PATH/cover_db/coverage.html";
