package C4::Reports;

# Copyright 2007 Liblime Ltd
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use CGI;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;
use C4::Debug;
# use Smart::Comments;
# use Data::Dumper;

BEGIN {
    # set the version for version checking
    $VERSION = 0.13;
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

=over 4

my $delims = GetDelimiterChoices;

=back

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

    return CGI::scrolling_list(
                -name     => 'sep',
                -id       => 'sep',
                -default  => $default,
                -values   => \@dels,
                -size     => 1,
                -multiple => 0 );
}

1;

__END__

=head1 AUTHOR

Jesse Weaver <jesse.weaver@liblime.com>

=cut
