package Koha::REST::V1::Patrons;

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

use Koha::Patrons;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Patrons

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Patron objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $attributes = {};
        my $args = $c->validation->output;
        my ( $params, $reserved_params ) = $c->extract_reserved_params( $args );

        # Merge sorting into query attributes
        $c->dbic_merge_sorting({ attributes => $attributes, params => $reserved_params });

        # Merge pagination into query attributes
        $c->dbic_merge_pagination({ filter => $attributes, params => $reserved_params });

        my $restricted = $args->{restricted};

        $params = _to_model($params)
            if defined $params;
        # deal with string params
        $params = $c->build_query_params( $params, $reserved_params );

        # translate 'restricted' => 'debarred'
        $params->{debarred} = { '!=' => undef }
          if $restricted;

        my $patrons = Koha::Patrons->search( $params, $attributes );
        if ( $patrons->is_paged ) {
            $c->add_pagination_headers(
                {
                    total  => $patrons->pager->total_entries,
                    params => $args,
                }
            );
        }
        my @patrons = $patrons->as_list;
        @patrons = map { _to_api( $_->TO_JSON ) } @patrons;
        return $c->render( status => 200, openapi => \@patrons );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => $_->{msg} }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}


=head3 get

Controller function that handles retrieving a single Koha::Patron object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);

    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    return $c->render( status => 200, openapi => _to_api( $patron->TO_JSON ) );
}

=head3 add

Controller function that handles adding a new Koha::Patron object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $body = _to_model( $c->validation->param('body') );

        my $patron = Koha::Patron->new( _to_model($body) )->store;
        $patron    = _to_api( $patron->TO_JSON );

        return $c->render( status => 201, openapi => $patron );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }
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
                        . $Koha::REST::V1::Patrons::to_api_mapping->{ $_->broken_fk }
                        . " does not exist"
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                          error => "Given "
                        . $Koha::REST::V1::Patrons::to_api_mapping->{ $_->parameter }
                        . " does not exist"
                }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }
    };
}


=head3 update

Controller function that handles updating a Koha::Patron object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find( $patron_id );

    unless ($patron) {
         return $c->render(
             status  => 404,
             openapi => { error => "Patron not found" }
         );
     }

    return try {
        my $body = _to_model($c->validation->param('body'));

        $patron->set($body)->store;
        $patron->discard_changes;
        return $c->render( status => 200, openapi => $patron );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => {
                    error => "Something went wrong, check Koha logs for details."
                }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Given " .
                            $Koha::REST::V1::Patrons::to_api_mapping->{$_->broken_fk}
                            . " does not exist" }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::MissingParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Missing mandatory parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Invalid parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::NoChanges') ) {
            return $c->render(
                status  => 204,
                openapi => { error => "No changes have been made" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => {
                    error =>
                      "Something went wrong, check Koha logs for details."
                }
            );
        }
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron;

    return try {
        $patron = Koha::Patrons->find( $c->validation->param('patron_id') );

        # check if loans, reservations, debarrment, etc. before deletion!
        my $res = $patron->delete;
        return $c->render( status => 200, openapi => {} );
    }
    catch {
        unless ($patron) {
            return $c->render(
                status  => 404,
                openapi => { error => "Patron not found" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => {
                    error =>
                      "Something went wrong, check Koha logs for details."
                }
            );
        }
    };
}

=head3 _to_api

Helper function that maps unblessed Koha::Patron objects into REST api
attribute names.

=cut

sub _to_api {
    my $patron    = shift;
    my $patron_id = $patron->{ borrowernumber };

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::Patrons::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::Patrons::to_api_mapping->{$column};
        if (    exists $patron->{ $column }
             && defined $mapped_column )
        {
            # key != undef
            $patron->{ $mapped_column } = delete $patron->{ $column };
        }
        elsif (    exists $patron->{ $column }
                && !defined $mapped_column )
        {
            # key == undef
            delete $patron->{ $column };
        }
    }

    # Calculate the 'restricted' field
    my $patron_obj = Koha::Patrons->find( $patron_id );
    $patron->{ restricted } = ($patron_obj->is_debarred) ? Mojo::JSON->true : Mojo::JSON->false;

    return $patron;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Patron
attribute names.

=cut

sub _to_model {
    my $patron = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::Patrons::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::Patrons::to_model_mapping->{$attribute};
        if (    exists $patron->{ $attribute }
             && defined $mapped_attribute )
        {
            # key => !undef
            $patron->{ $mapped_attribute } = delete $patron->{ $attribute };
        }
        elsif (    exists $patron->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key => undef / to be deleted
            delete $patron->{ $attribute };
        }
    }

    # TODO: Get rid of this once write operations are based on Koha::Patron
    if ( exists $patron->{lost} ) {
        $patron->{lost} = ($patron->{lost}) ? 1 : 0;
    }

    if ( exists $patron->{ gonenoaddress} ) {
        $patron->{gonenoaddress} = ($patron->{gonenoaddress}) ? 1 : 0;
    }

    return $patron;
}

=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    borrowernotes       => 'staff_notes',
    borrowernumber      => 'patron_id',
    branchcode          => 'library_id',
    categorycode        => 'category_id',
    checkprevcheckout   => 'check_previous_checkout',
    contactfirstname    => undef, # Unused
    contactname         => undef, # Unused
    contactnote         => 'altaddress_notes',
    contacttitle        => undef, # Unused
    dateenrolled        => 'date_enrolled',
    dateexpiry          => 'expiry_date',
    dateofbirth         => 'date_of_birth',
    debarred            => undef, # replaced by 'restricted'
    debarredcomment     => undef, # calculated, API consumers will use /restrictions instead
    emailpro            => 'secondary_email',
    flags               => undef, # permissions manipulation handled in /permissions
    gonenoaddress       => 'incorrect_address',
    guarantorid         => 'guarantor_id',
    lastseen            => 'last_seen',
    lost                => 'patron_card_lost',
    opacnote            => 'opac_notes',
    othernames          => 'other_name',
    password            => undef, # password manipulation handled in /password
    phonepro            => 'secondary_phone',
    relationship        => 'relationship_type',
    sex                 => 'gender',
    smsalertnumber      => 'sms_number',
    sort1               => 'statistics_1',
    sort2               => 'statistics_2',
    streetnumber        => 'street_number',
    streettype          => 'street_type',
    zipcode             => 'postal_code',
    B_address           => 'altaddress_address',
    B_address2          => 'altaddress_address2',
    B_city              => 'altaddress_city',
    B_country           => 'altaddress_country',
    B_email             => 'altaddress_email',
    B_phone             => 'altaddress_phone',
    B_state             => 'altaddress_state',
    B_streetnumber      => 'altaddress_street_number',
    B_streettype        => 'altaddress_street_type',
    B_zipcode           => 'altaddress_postal_code',
    altcontactaddress1  => 'altcontact_address',
    altcontactaddress2  => 'altcontact_address2',
    altcontactaddress3  => 'altcontact_city',
    altcontactcountry   => 'altcontact_country',
    altcontactfirstname => 'altcontact_firstname',
    altcontactphone     => 'altcontact_phone',
    altcontactsurname   => 'altcontact_surname',
    altcontactstate     => 'altcontact_state',
    altcontactzipcode   => 'altcontact_postal_code'
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    altaddress_notes         => 'contactnote',
    category_id              => 'categorycode',
    check_previous_checkout  => 'checkprevcheckout',
    date_enrolled            => 'dateenrolled',
    date_of_birth            => 'dateofbirth',
    expiry_date              => 'dateexpiry',
    gender                   => 'sex',
    guarantor_id             => 'guarantorid',
    incorrect_address        => 'gonenoaddress',
    last_seen                => 'lastseen',
    library_id               => 'branchcode',
    opac_notes               => 'opacnote',
    other_name               => 'othernames',
    patron_card_lost         => 'lost',
    patron_id                => 'borrowernumber',
    postal_code              => 'zipcode',
    relationship_type        => 'relationship',
    restricted               => undef,
    secondary_email          => 'emailpro',
    secondary_phone          => 'phonepro',
    sms_number               => 'smsalertnumber',
    staff_notes              => 'borrowernotes',
    statistics_1             => 'sort1',
    statistics_2             => 'sort2',
    street_number            => 'streetnumber',
    street_type              => 'streettype',
    altaddress_address       => 'B_address',
    altaddress_address2      => 'B_address2',
    altaddress_city          => 'B_city',
    altaddress_country       => 'B_country',
    altaddress_email         => 'B_email',
    altaddress_phone         => 'B_phone',
    altaddress_state         => 'B_state',
    altaddress_street_number => 'B_streetnumber',
    altaddress_street_type   => 'B_streettype',
    altaddress_postal_code   => 'B_zipcode',
    altcontact_firstname     => 'altcontactfirstname',
    altcontact_surname       => 'altcontactsurname',
    altcontact_address       => 'altcontactaddress1',
    altcontact_address2      => 'altcontactaddress2',
    altcontact_city          => 'altcontactaddress3',
    altcontact_state         => 'altcontactstate',
    altcontact_postal_code   => 'altcontactzipcode',
    altcontact_country       => 'altcontactcountry',
    altcontact_phone         => 'altcontactphone'
};

1;
