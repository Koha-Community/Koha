#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Parts copyright 2011 BibLibre
#
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


=head1 setdebar.pl

script to set or lift debarred status
written 2/8/04
by oleonard@athenscounty.lib.oh.us

=cut

use strict;
use warnings;

use CGI;
use C4::Context;
use C4::Auth;

my $input = new CGI;

checkauth( $input, 0, { borrowers => 1 }, 'intranet' );

my $borrowernumber = $input->param('borrowernumber');

my $dbh = C4::Context->dbh;
my $sth =
  $dbh->prepare("Update borrowers set debarred = NULL where borrowernumber = ?");
$sth->execute( $borrowernumber );
$sth->finish;

print $input->redirect(
    "/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
