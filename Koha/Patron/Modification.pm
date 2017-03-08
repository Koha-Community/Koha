package Koha::Patron::Modification;

# Copyright ByWater Solutions 2014
# Copyright Koha-Suomi Oy 2016
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
use Email::Valid;

use Koha::Database;
use Koha::Exceptions;
use Koha::Patrons;

use Koha::Patron::Modifications;
use Koha::Exceptions::Patron::Modification;
use Koha::Patron::Attribute;
use Koha::Patron::Attributes;
use Koha::Patron::Modifications;

use Digest::MD5 qw( md5_hex );
use JSON;
use List::MoreUtils qw( uniq );
use Try::Tiny;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Modification - Class represents a request to modify or create a patron

=head2 Class Methods

=cut

=head2 new

=cut

sub new {
    my $class = shift;
    my ($attributes) = @_;

    # Generate a verification_token unless provided
    if ( ref $attributes && !$attributes->{verification_token} ) {
        my $verification_token = md5_hex( time().{}.rand().{}.$$ );
        while ( Koha::Patron::Modifications->search( {
                    verification_token => $verification_token
                } )->count()
        ) {
            $verification_token = md5_hex( time().{}.rand().{}.$$ );
        }
        $attributes->{verification_token} = $verification_token;
    }

    return $class->SUPER::new(@_);
}

=head2 store

=cut

sub store {
    my ($self) = @_;

    if ( $self->verification_token ) {
        if (Koha::Patron::Modifications->search(
                { verification_token => $self->verification_token }
            )->count()
            )
        {
            Koha::Exceptions::Patron::Modification::DuplicateVerificationToken->throw(
                "Duplicate verification token " . $self->verification_token );
        }
    }

    if ( $self->extended_attributes ) {
        try {
            my $json_parser = JSON->new;
            $json_parser->decode( $self->extended_attributes );
        }
        catch {
            Koha::Exceptions::Patron::Modification::InvalidData->throw(
                'The passed extended_attributes is not valid JSON');
        };
    }

    return $self->SUPER::store();
}

=head2 approve

$m->approve();

Commits the pending modifications to the borrower record and removes
them from the modifications table.

=cut

sub approve {
    my ($self) = @_;

    my $data = $self->unblessed();
    my $extended_attributes;

    delete $data->{timestamp};
    delete $data->{verification_token};
    delete $data->{extended_attributes};

    foreach my $key ( keys %$data ) {
        delete $data->{$key} unless ( defined( $data->{$key} ) );
    }

    my $patron = Koha::Patrons->find( $self->borrowernumber );

    return unless $patron;

    $patron->set($data);

    # Take care of extended attributes
    if ( $self->extended_attributes ) {
        $extended_attributes = try { from_json( $self->extended_attributes ) }
        catch {
            Koha::Exceptions::Patron::Modification::InvalidData->throw(
                'The passed extended_attributes is not valid JSON');
        };
    }

    $self->_result->result_source->schema->txn_do(
        sub {
            try {
                $patron->store();

                # Deal with attributes
                my @codes
                    = uniq( map { $_->{code} } @{$extended_attributes} );
                foreach my $code (@codes) {
                    map { $_->delete } Koha::Patron::Attributes->search(
                        {   borrowernumber => $patron->borrowernumber,
                            code           => $code
                        }
                    );
                }
                foreach my $attr ( @{$extended_attributes} ) {
                    Koha::Patron::Attribute->new(
                        {   borrowernumber => $patron->borrowernumber,
                            code           => $attr->{code},
                            attribute      => $attr->{value}
                        }
                    )->store
                        if $attr->{value} # there's a value
                           or
                          (    defined $attr->{value} # there's a value that is 0, and not
                            && $attr->{value} ne ""   # the empty string which means delete
                            && $attr->{value} == 0
                          );
                }
            }
            catch {
                if ( $_->isa('DBIx::Class::Exception') ) {
                    Koha::Exceptions::Patron::Modification->throw( $_->{msg} );
                }
                else {
                    Koha::Exceptions::Patron::Modification->throw($@);
                }
            };
        }
    );

    return $self->delete();
}

=head2 validate_changes

my $patron_modifications = Koha::Patron::Modifications->new->validate_changes($body)->store;

Validates patron modifications

Throws Koha::Exceptions::MissingParameter if missing mandatory parameters
Throws Koha::Exceptions::BadParameter if modifications contain invalid parameters
Throws Koha::Exceptions::NoChanges if no changes have been made

=cut

sub validate_changes {
    my ($self, $changed_patron, $action) = @_;

    # delete empty fields
    $changed_patron = $changed_patron->unblessed if ref($changed_patron) eq "Koha::Patron";
    foreach my $key ( keys %{$changed_patron} ) {
        delete $changed_patron->{$key} unless $changed_patron->{$key};
        # delete fields that are not modifiable
        eval { $self->_result->get_column($key) };
        delete $changed_patron->{$key} if $@;
    }

    my $mandatory_fields;
    my $BorrowerMandatoryField =
      C4::Context->preference("PatronSelfRegistrationBorrowerMandatoryField");

    my @fields = split( /\|/, $BorrowerMandatoryField );
    foreach (@fields) {
        $mandatory_fields->{$_} = 1;
    }

    if ( $action eq 'create' || $action eq 'new' ) {
        $mandatory_fields->{'email'} = 1
          if C4::Context->boolean_preference(
            'PatronSelfRegistrationVerifyByEmail');
    }

    my @empty_mandatory_fields;
    delete $mandatory_fields->{'cardnumber'};

    foreach my $key ( keys %$mandatory_fields ) {
        push( @empty_mandatory_fields, $key )
          unless ( defined( $changed_patron->{$key} ) && $changed_patron->{$key} );
    }
    Koha::Exceptions::MissingParameter->throw(
        error => "Missing mandatory parameter",
        parameter => [@empty_mandatory_fields],
    ) if @empty_mandatory_fields;

    my $minpw = C4::Context->preference('minPasswordLength');
    my @invalidFields;
    if ($changed_patron->{'email'}) {
        unless ( Email::Valid->address($changed_patron->{'email'}) ) {
            push(@invalidFields, "email");
        } elsif ( C4::Context->preference("PatronSelfRegistrationEmailMustBeUnique") ) {
            my $patrons_with_same_email = Koha::Patrons->search( { email => $changed_patron->{email} })->count;
            if ( $patrons_with_same_email ) {
                push @invalidFields, "duplicate_email";
            }
        }
    }
    if ($changed_patron->{'emailpro'}) {
        push(@invalidFields, "emailpro") if (!Email::Valid->address($changed_patron->{'emailpro'}));
    }
    if ($changed_patron->{'B_email'}) {
        push(@invalidFields, "B_email") if (!Email::Valid->address($changed_patron->{'B_email'}));
    }
    if ($changed_patron->{'password'}  && $minpw && (length($changed_patron->{'password'}) < $minpw) ) {
       push(@invalidFields, "password_invalid");
    }
    if ($changed_patron->{'password'} ) {
       push(@invalidFields, "password_spaces") if ($changed_patron->{'password'} =~ /^\s/ or $changed_patron->{'password'} =~ /\s$/);
    }
    Koha::Exceptions::BadParameter->throw(
        error => "Invalid fields",
        parameter => [@invalidFields],
    ) if @invalidFields;

    my $current_data = Koha::Patrons->find({ borrowernumber => $changed_patron->{borrowernumber} })->unblessed;
    foreach my $key ( keys %{$changed_patron} ) {
        if ( $current_data->{$key} eq $changed_patron->{$key} ) {
            delete $changed_patron->{$key};
        }
    }

    Koha::Exceptions::NoChanges->throw(
        error => "No changes has been made",
    ) unless keys %{$changed_patron};

    $self->set($changed_patron)->borrowernumber($current_data->{borrowernumber});
    return $self;
}

=head3 type

=cut

sub _type {
    return 'BorrowerModification';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
