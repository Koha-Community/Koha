package Koha::REST::V1::ERM::EHoldings::Packages::Local;

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

use Koha::ERM::EHoldings::Packages;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift or return;
    return try {
        my $packages_set =
          Koha::ERM::EHoldings::Packages->search( { 'me.external_id' => undef } );
        my $packages     = $c->objects->search($packages_set);
        return $c->render( status => 200, openapi => $packages );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

=cut

sub get {
    my $c = shift or return;

    return try {
        my $package_id = $c->param('package_id');
        my $package    = $c->objects->find(
            Koha::ERM::EHoldings::Packages->search,
            $package_id
        );

        return $c->render_resource_not_found("Package")
            unless $package;

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
    my $c = shift or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $package_agreements  = delete $body->{package_agreements}  // [];
                my $extended_attributes = delete $body->{extended_attributes} // [];
                delete $body->{external_id} unless $body->{external_id};

                my $package = Koha::ERM::EHoldings::Package->new_from_api($body)->store;
                $package->package_agreements($package_agreements);

                my @extended_attributes =
                    map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
                $package->extended_attributes( \@extended_attributes );

                $c->res->headers->location($c->req->url->to_string . '/' . $package->package_id);
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($package),
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
    my $c = shift or return;

    my $package_id = $c->param('package_id');
    my $package = Koha::ERM::EHoldings::Packages->find( $package_id );

    return $c->render_resource_not_found("Package")
        unless $package;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $package_agreements  = delete $body->{package_agreements}  // [];
                my $extended_attributes = delete $body->{extended_attributes} // [];
                delete $body->{external_id} unless $body->{external_id};

                $package->set_from_api($body)->store;

                # FIXME If there is no package_agreements and external_id is set, we could delete the row
                # ie. It's coming from EBSCO and we don't have local data linked to it
                $package->package_agreements($package_agreements);

                my @extended_attributes =
                    map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
                $package->extended_attributes( \@extended_attributes );

                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($package),
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
    my $c = shift or return;

    my $package = Koha::ERM::EHoldings::Packages->find( $c->param('package_id') );

    return $c->render_resource_not_found("Package")
        unless $package;

    return try {
        $package->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
