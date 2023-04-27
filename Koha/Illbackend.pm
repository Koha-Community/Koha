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

    #FIXME: Currently fetching all requests, it'd be great if we could fetch distinct(status).
    # Even doing it with distinct status, we need the ILL request object, so that strings_map works and
    # the ILL request returns the correct status and info respective to its backend.
    my $ill_requests = Koha::Illrequests->search(
            {backend => $backend_id},
            # {
            #     columns => [ qw/status/ ],
            #     group_by => [ qw/status/ ],
            # }
        );

    my @data;
    while (my $request = $ill_requests->next) {
        my $status_data = $request->strings_map;

        foreach my $status_class ( qw(status_alias status) ){
            if ($status_data->{$status_class}){
                push @data, {
                    $status_data->{$status_class}->{str} ? (str => $status_data->{$status_class}->{str}) :
                        $status_data->{$status_class}->{code} ? (str => $status_data->{$status_class}->{code}) : (),
                    $status_data->{$status_class}->{code} ? (code => $status_data->{$status_class}->{code}) : (),
                }
            }
        }
    }

    # Remove duplicate statuses
    my %seen;
    @data =  grep { my $e = $_; my $key = join '___', map { $e->{$_}; } sort keys %$_;!$seen{$key}++ } @data;

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
