package C4::Reports;

# Copyright 2007 Liblime Ltd
#
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

use strict;
#use warnings; FIXME - Bug 2505
use CGI;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;
use C4::Debug;

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        GetDelimiterChoices
    );
}

=head1 NAME

C4::Reports - Module for generating reports 

=head1 DESCRIPTION

This module contains functions common to reports.

=head1 EXPORTED FUNCTIONS

=head2 GetDelimiterChoices

  my $delims = GetDelimiterChoices;

This will return a list of all the available delimiters.

=cut

sub GetDelimiterChoices {
    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare("
      SELECT options, value
      FROM systempreferences
      WHERE variable = 'delimiter'
    ");

    $sth->execute();

    my ($choices, $default) = $sth->fetchrow;
    my @dels = split /\|/, $choices;

    return {
        values  => \@dels,
        default => $default,
    };
}

1;

__END__

=head1 AUTHOR

Jesse Weaver <jesse.weaver@liblime.com>

=cut
