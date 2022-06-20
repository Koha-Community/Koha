package Koha::REST::V1::ERM::EHoldings::Packages::Manual;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::ERM::EHoldings::Packages;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

sub list {
    my $c = shift->openapi->valid_input or return;
    return try {
        my $packages_set = Koha::ERM::EHoldings::Packages->new;
        my $packages     = $c->objects->search($packages_set);
        return $c->render( status => 200, openapi => $packages );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $package_id = $c->validation->param('package_id');
        my $package = $c->objects->find( Koha::ERM::EHoldings::Packages->search,
            $package_id );

        unless ($package) {
            return $c->render(
                status  => 404,
                openapi => { error => "Package not found" }
            );
        }

        return $c->render(
            status  => 200,
            openapi => $package
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::ERM::EHoldings::Package object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                my $package_agreements = delete $body->{package_agreements} // [];

                my $package = Koha::ERM::EHoldings::Package->new_from_api($body)->store;
                $package->package_agreements($package_agreements);

                $c->res->headers->location($c->req->url->to_string . '/' . $package->package_id);
                return $c->render(
                    status  => 201,
                    openapi => $package->to_api
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::ERM::EHoldings::Package->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::ERM::EHoldings::Package object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $package_id = $c->validation->param('package_id');
    my $package = Koha::ERM::EHoldings::Packages->find( $package_id );

    unless ($package) {
        return $c->render(
            status  => 404,
            openapi => { error => "Package not found" }
        );
    }

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                my $package_agreements = delete $body->{package_agreements} // [];

                $package->set_from_api($body)->store;
                $package->package_agreements($package_agreements);

                $c->res->headers->location($c->req->url->to_string . '/' . $package->package_id);
                return $c->render(
                    status  => 200,
                    openapi => $package->to_api
                );
            }
        );
    }
    catch {
        my $to_api_mapping = Koha::ERM::EHoldings::Package->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
};

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $package = Koha::ERM::EHoldings::Packages->find( $c->validation->param('package_id') );
    unless ($package) {
        return $c->render(
            status  => 404,
            openapi => { error => "Package not found" }
        );
    }

    return try {
        $package->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


1;
