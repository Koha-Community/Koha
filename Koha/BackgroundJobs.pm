package Koha::BackgroundJobs;

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

use Koha::BackgroundJob;

use base qw(Koha::Objects);

=head1 NAME

Koha::BackgroundJobs - Koha BackgroundJob Object set class

=head1 API

=head2 Class methods

=head3 search_limited

  my $background_jobs = Koha::BackgroundJobs->search_limited( $params, $attributes );

Returns all background jobs the logged in user should be allowed to see

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $can_manage_background_jobs;
    my $logged_in_user;
    my $userenv = C4::Context->userenv;
    if ( $userenv and $userenv->{number} ) {
        $logged_in_user             = Koha::Patrons->find( $userenv->{number} );
        $can_manage_background_jobs = $logged_in_user->has_permission( { parameters => 'manage_background_jobs' } );
    }

    return $self->search( $params, $attributes ) if $can_manage_background_jobs;
    my $id = $logged_in_user ? $logged_in_user->borrowernumber : undef;
    return $self->search( { borrowernumber => $id } )->search( $params, $attributes );
}

=head3 filter_by_current

    my $current_jobs = $jobs->filter_by_current;

Returns a new resultset, filtering out finished jobs.

=cut

sub filter_by_current {
    my ($self) = @_;

    return $self->search( { status => { not_in => [ 'cancelled', 'failed', 'finished' ] } } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'BackgroundJob';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::BackgroundJob';
}

1;
