package Koha::REST::V1::BackgroundJobs;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::BackgroundJobs;

use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $background_jobs_set = Koha::BackgroundJobs->new;
        my $background_jobs     = $c->objects->search($background_jobs_set);
        return $c->render( status => 200, openapi => $background_jobs );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $background_job_id = $c->validation->param('background_job_id');
        my $patron            = $c->stash('koha.user');

        my $can_manage_background_jobs =
          $patron->has_permission( { parameters => 'manage_background_jobs' } );

        my $background_job = Koha::BackgroundJobs->find($background_job_id);

        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        ) unless $background_job;

        return $c->render(
            status  => 403,
            openapi => { error => "Cannot see background job info" }
          )
          if !$can_manage_background_jobs
          && $background_job->borrowernumber != $patron->borrowernumber;

        return $c->render(
            status  => 200,
            openapi => $background_job->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
