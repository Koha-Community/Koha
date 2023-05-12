package Koha::REST::V1::Illbatches;

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

use Koha::Illbatches;
use Koha::IllbatchStatuses;
use Koha::Illrequests;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Illbatches

=head2 Operations

=head3 list

Return a list of available ILL batches

=cut

sub list {
    my $c = shift->openapi->valid_input;

    #FIXME: This should be $c->objects-search
    my @batches = Koha::Illbatches->search()->as_list;

    #FIXME: Below should be coming from $c->objects accessors
    # Get all patrons associated with all our batches
    # in one go
    my $patrons = {};
    foreach my $batch(@batches) {
        my $patron_id = $batch->borrowernumber;
        $patrons->{$patron_id} = 1
    };
    my @patron_ids = keys %{$patrons};
    my $patron_results = Koha::Patrons->search({
        borrowernumber => { -in => \@patron_ids }
    });

    # Get all branches associated with all our batches
    # in one go
    my $branches = {};
    foreach my $batch(@batches) {
        my $branch_id = $batch->branchcode;
        $branches->{$branch_id} = 1
    };
    my @branchcodes = keys %{$branches};
    my $branch_results = Koha::Libraries->search({
        branchcode => { -in => \@branchcodes }
    });

    # Get all batch statuses associated with all our batches
    # in one go
    my $statuses = {};
    foreach my $batch(@batches) {
        my $code = $batch->statuscode;
        $statuses->{$code} = 1
    };
    my @statuscodes = keys %{$statuses};
    my $status_results = Koha::IllbatchStatuses->search({
        code => { -in => \@statuscodes }
    });

    # Populate the response
    my @to_return = ();
    foreach my $it_batch(@batches) {
        my $patron = $patron_results->find({ borrowernumber => $it_batch->borrowernumber});
        my $branch = $branch_results->find({ branchcode => $it_batch->branchcode });
        my $status = $status_results->find({ code => $it_batch->statuscode });
        push @to_return, {
            %{$it_batch->unblessed},
            patron         => $patron,
            branch         => $branch,
            status         => $status,
            requests_count => $it_batch->requests_count
        };
    }

    return $c->render( status => 200, openapi => \@to_return );
}

=head3 get

Get one batch

=cut

sub get {
    my $c = shift->openapi->valid_input;

    my $batchid = $c->validation->param('illbatch_id');

    my $batch = Koha::Illbatches->find($batchid);

    if (not defined $batch) {
        return $c->render(
            status => 404,
            openapi => { error => "ILL batch not found" }
        );
    }

    return $c->render(
        status => 200,
        openapi => {
            %{$batch->unblessed},
            patron         => $batch->patron->unblessed,
            branch         => $batch->branch->unblessed,
            status         => $batch->status->unblessed,
            requests_count => $batch->requests_count
        }
    );
}

=head3 add

Add a new batch

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->validation->param('body');

    # We receive cardnumber, so we need to look up the corresponding
    # borrowernumber
    my $patron = Koha::Patrons->find({ cardnumber => $body->{cardnumber} });

    if ( not defined $patron ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Patron with cardnumber " . $body->{cardnumber} . " not found" }
        );
    }

    delete $body->{cardnumber};
    $body->{borrowernumber} = $patron->borrowernumber;

    return try {
        my $batch = Koha::Illbatch->new( $body );
        $batch->create_and_log;
        $c->res->headers->location( $c->req->url->to_string . '/' . $batch->id );

        my $ret = {
            %{$batch->unblessed},
            patron           => $batch->patron->unblessed,
            branch           => $batch->branch->unblessed,
            status           => $batch->status->unblessed,
            requests_count   => 0
        };

        return $c->render(
            status  => 201,
            openapi => $ret
        );
    }
    catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => "A batch named " . $body->{name} . " already exists" }
                );
            }
        }
        $c->unhandled_exception($_);
    };
}

=head3 update

Update a batch

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $batch = Koha::Illbatches->find( $c->validation->param('illbatch_id') );

    if ( not defined $batch ) {
        return $c->render(
            status  => 404,
            openapi => { error => "ILL batch not found" }
        );
    }

    my $params = $c->req->json;
    delete $params->{cardnumber};

    return try {
        $batch->update_and_log( $params );

        my $ret = {
            %{$batch->unblessed},
            patron         => $batch->patron->unblessed,
            branch         => $batch->branch->unblessed,
            status         => $batch->status->unblessed,
            requests_count => $batch->requests_count
        };

        return $c->render(
            status  => 200,
            openapi => $ret
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Delete a batch

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $batch = Koha::Illbatches->find( $c->validation->param( 'illbatch_id' ) );

    if ( not defined $batch ) {
        return $c->render( status => 404, openapi => { error => "ILL batch not found" } );
    }

    return try {
        $batch->delete_and_log;
        return $c->render( status => 204, openapi => '');
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
