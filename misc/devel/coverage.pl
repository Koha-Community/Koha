#!/usr/bin/perl

# Copyright 2015 BibLibre
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

coverage.pl

=head1 SYNOPSIS

./misc/devel/coverage.pl

=head1 DESCRIPTION

This script make a cover on all files to see which modules are not tested yet

=cut

use Modern::Perl;
use C4::Context;

my $KOHA_PATH = C4::Context->config("intranetdir");

chdir $KOHA_PATH;

eval{
	require Devel::Cover;
};

if ($@) {
	say "Devel::Cover needs to be installed";
	exit 1;
}

#Delete old coverage
system("cover -delete");

#Start the cover
system("PERL5OPT=-MDevel::Cover /usr/bin/prove -r t/");

#Create the HTML output
system("cover");

say("file://$KOHA_PATH/cover_db/coverage.html");