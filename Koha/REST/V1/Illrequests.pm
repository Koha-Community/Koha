package Koha::REST::V1::Illrequests;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Illrequests;
use Koha::Library;

sub list {
    my ($c, $args, $cb) = @_;

    my $filter;
    $args //= {};
    my $output = [];

    # Create a hash where all keys are embedded values
    # Enables easy checking
    my %embed;
    if (defined $args->{embed}) {
        %embed = map { $_ => 1 }  @{$args->{embed}};
        delete $args->{embed};
    }

    for my $filter_param ( keys %$args ) {
        my @values = split(/,/, $args->{$filter_param});
        $filter->{$filter_param} = \@values;
    }

    my $requests = Koha::Illrequests->search($filter);

    while (my $request = $requests->next) {
        my $unblessed = $request->unblessed;
        # Add the request's id_prefix
        $unblessed->{id_prefix} = $request->id_prefix;
        # Augment the request response with patron details
        # if appropriate
        if (defined $embed{patron}) {
            my $patron = $request->patron;
            $unblessed->{patron} = {
                firstname  => $patron->firstname,
                surname    => $patron->surname,
                cardnumber => $patron->cardnumber
            };
        }
        # Augment the request response with metadata details
        # if appropriate
        if (defined $embed{metadata}) {
            $unblessed->{metadata} = $request->metadata;
        }
        # Augment the request response with status details
        # if appropriate
        if (defined $embed{capabilities}) {
            $unblessed->{capabilities} = $request->capabilities;
        }
        # Augment the request response with branch details
        # if appropriate
        if (defined $embed{branch}) {
            $unblessed->{branch} = Koha::Libraries->find(
                $request->branchcode
            )->unblessed;
        }
        push @{$output}, $unblessed
    }

    return $c->$cb( $output, 200 );

}

1;
