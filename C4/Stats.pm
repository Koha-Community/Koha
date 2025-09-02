package C4::Stats;

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use base 'Exporter';

BEGIN {
    our @EXPORT_OK = qw(
        UpdateStats
    );
}

use Koha::Statistics;

=head1 NAME

C4::Stats - Update Koha statistics (log)

=head1 SYNOPSIS

    use C4::Stats;

=head1 DESCRIPTION

The functions of this module deals with statistics table of Koha database.

=head1 FUNCTIONS

=head2 UpdateStats

    C4::Stats::UpdateStats($params);

    This is a (legacy) alias for Koha::Statistic->new($params)->store.
    Please see Koha::Statistic module.

=cut

sub UpdateStats {
    my $params = shift;
    Koha::Statistic->new($params)->store;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut
