package Koha::Checkouts;

# Copyright ByWater Solutions 2015
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
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use C4::Context;
use Koha::Checkout;
use Koha::Database;

use base qw(Koha::Objects);

=head1 NAME

Koha::Checkouts - Koha Checkout object set class

=head1 API

=head2 Class Methods

=cut

=head3 calculate_dropbox_date

my $dt = Koha::Checkouts::calculate_dropbox_date();

=cut

sub calculate_dropbox_date {
    my $userenv    = C4::Context->userenv;
    my $branchcode = $userenv->{branch} // q{};

    my $calendar = Koha::Calendar->new( branchcode => $branchcode );
    my $today        = DateTime->now( time_zone => C4::Context->tz() );
    my $dropbox_date = $calendar->addDate( $today, -1 );

    return $dropbox_date;
}

=head3 type

=cut

sub _type {
    return 'Issue';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Checkout';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
