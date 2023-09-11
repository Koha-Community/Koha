package Koha::Illbackend;

# Copyright PTFS Europe 2023
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

use Modern::Perl;

use base qw(Koha::Object);

=head1 NAME

Koha::Illbackend - Koha Illbackend Object class

=head2 Class methods

=head3 new

New illbackend

=cut

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

=head3 existing_statuses

Return a list of existing ILL statuses

=cut

sub existing_statuses {
    my ( $self, $backend_id ) = @_;

    my @data;

    # NOTE: This query fetches all distinct status's found in the database for this backend.
    # We need the 'status' field for obvious reasons, the 'backend' field is required to not
    # throw 'Koha::Exceptions::Ill::InvalidBackendId' when we're converting to a Koha object.
    # Finally, to get around 'ONLY_FULL_GROUP_BY', we have to be explicit about which
    # 'request_id' we want to return, hense the 'MAX' call.
    my $ill_requests = Koha::Illrequests->search(
        { backend => $backend_id },
        {
            select   => [ 'status', \'MAX(illrequest_id)', 'backend' ],
            as       => [qw/ status illrequest_id backend /],
            group_by => [qw/status backend/],
            order_by => [qw/status backend/],
        }
    );
    while ( my $request = $ill_requests->next ) {
        my $status_data = $request->strings_map;

        if ( $status_data->{status} ) {
            push @data, {
                  $status_data->{status}->{str}  ? ( str => $status_data->{status}->{str} )
                : $status_data->{status}->{code} ? ( str => $status_data->{status}->{code} )
                : (),
                $status_data->{status}->{code} ? ( code => $status_data->{status}->{code} ) : (),
            };
        }
    }

    # Now do the same to get all status_aliases
    $ill_requests = Koha::Illrequests->search(
        { backend => $backend_id },
        {
            select   => [ 'status_alias', \'MAX(illrequest_id)', 'backend' ],
            as       => [qw/ status_alias illrequest_id backend /],
            group_by => [qw/status_alias backend/],
            order_by => [qw/status_alias backend/],
        }
    );
    while ( my $request = $ill_requests->next ) {
        my $status_data = $request->strings_map;

        if ( $status_data->{status_alias} ) {
            push @data, {
                  $status_data->{status_alias}->{str}  ? ( str => $status_data->{status_alias}->{str} )
                : $status_data->{status_alias}->{code} ? ( str => $status_data->{status_alias}->{code} )
                : (),
                $status_data->{status_alias}->{code} ? ( code => $status_data->{status_alias}->{code} ) : (),
            };
        }
    }

    return \@data;
}

=head3 embed

    Embed info in backend for API response

=cut

sub embed {
    my ( $self, $backend_id, $embed_header ) = @_;
    $embed_header ||= q{};

    my $return_embed;

    foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
        if ( $embed_req eq 'statuses+strings' ) {
            $return_embed->{statuses} = $self->existing_statuses( $backend_id );
        }
    }
    return $return_embed;
}

=head2 Internal methods

=head3 _type

    my $type = Koha::Illbackend->_type;

Return this object's type

=cut

sub _type {
    return 'Illbackend';
}

=head1 AUTHOR

Pedro Amorim <pedro.amorim@ptfs-europe.com>

=cut

1;
