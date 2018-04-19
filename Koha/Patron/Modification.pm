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
use C4::Log; # logaction
use C4::Members;

use Koha::Patron::Modifications;
use Koha::Exceptions::Patron::Modification;
use Koha::Patron::Attribute;
use Koha::Patron::Attributes;
use Koha::Patron::Message::Preferences;
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

    # Delete Koha::Patron columns that are not modifiable via this class
    my @columns = Koha::Patron::Modifications->columns;
    my @patron_columns = Koha::Patrons->columns;
    foreach my $attr (keys %$attributes) {
        if (grep(/^$attr$/, @patron_columns) && !grep(/^$attr$/, @columns)) {
            delete $attributes->{$attr};
        }
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

    return $self->validate->SUPER::store();
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
    my $logdata = getModifiedPatronFieldsForLogs($data);
    logaction("MEMBERS", "MODIFY", $self->borrowernumber, "Approved patron's change request: $logdata") if C4::Context->preference("BorrowersLog");

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

                foreach my $pref (
                    @{Koha::Patron::Message::Preferences->search({
                        borrowernumber => $self->borrowernumber })->as_list
                    })
                {

                    $pref->fix_misconfigured_preference;
                }
            }
            catch {
                if ( $_->isa('DBIx::Class::Exception') ) {
                    Koha::Exceptions::Patron::Modification->throw( $_->{msg} );
                }
                elsif ( $_->can('rethrow') ) {
                    Koha::Exceptions::rethrow_exception($_);
                }
                else {
                    Koha::Exceptions::Patron::Modification->throw($@);
                }
            };
        }
    );

    return $self->delete();
}

=head2 deny

$m->deny();

Logs denied requests

=cut

sub deny {
    my ($self) = @_;

    my $data = $self->unblessed();

    delete $data->{timestamp};
    delete $data->{verification_token};
    delete $data->{extended_attributes};

    foreach my $key ( keys %$data ) {
        delete $data->{$key} unless ( defined( $data->{$key} ) );
    }

    my $logdata = C4::Members::getModifiedPatronFieldsForLogs($data);

    logaction("MEMBERS", "MODIFY", $self->borrowernumber, "Denied patron's change request: $logdata") if C4::Context->preference("BorrowersLog");

    return $self->delete();
}

=head2 validate_changes

my $patron_modifications = Koha::Patron::Modifications->new({
                                surname   => 'New',
                                firstname => 'Me',
                           })->store;

Validates patron modifications

Throws Koha::Exceptions::MissingParameter if missing mandatory parameters
Throws Koha::Exceptions::BadParameter if modifications contain invalid parameters
Throws Koha::Exceptions::NoChanges if no changes have been made

=cut

sub validate {
    my ($self) = @_;

    my $changes = $self->unblessed;
    delete $changes->{timestamp};
    delete $changes->{verification_token};

    my $mandatory_fields;
    my $BorrowerMandatoryField =
      C4::Context->preference("PatronSelfRegistrationBorrowerMandatoryField");

    my @fields = split( /\|/, $BorrowerMandatoryField );
    foreach (@fields) {
        $mandatory_fields->{$_} = 1;
    }

    my @empty_mandatory_fields;
    delete $mandatory_fields->{'cardnumber'};

    foreach my $key ( keys %$mandatory_fields ) {
        if ( exists $changes->{$key} && (
             !defined( $changes->{$key} ) || length( $changes->{$key} ) == 0 ) ) {
            push( @empty_mandatory_fields, $key );
        }
    }
    Koha::Exceptions::MissingParameter->throw(
        error => "Missing mandatory parameter",
        parameter => [@empty_mandatory_fields],
    ) if @empty_mandatory_fields;

    my $minpw = C4::Context->preference('minPasswordLength');
    my @invalidFields;
    if ($changes->{'email'}) {
        unless ( Email::Valid->address($changes->{'email'}) ) {
            push(@invalidFields, "email");
        } elsif ( C4::Context->preference("PatronSelfRegistrationEmailMustBeUnique") ) {
            my $patrons_with_same_email = Koha::Patrons->search( { email => $changes->{email} })->count;
            if ( $patrons_with_same_email ) {
                push @invalidFields, "duplicate_email";
            }
        }
    }
    if ($changes->{'emailpro'}) {
        push(@invalidFields, "emailpro") if (!Email::Valid->address($changes->{'emailpro'}));
    }
    if ($changes->{'B_email'}) {
        push(@invalidFields, "B_email") if (!Email::Valid->address($changes->{'B_email'}));
    }
    if ($changes->{'password'}  && $minpw && (length($changes->{'password'}) < $minpw) ) {
       push(@invalidFields, "password_invalid");
    }
    if ($changes->{'password'} ) {
       push(@invalidFields, "password_spaces") if ($changes->{'password'} =~ /^\s/ or $changes->{'password'} =~ /\s$/);
    }
    Koha::Exceptions::BadParameter->throw(
        error => "Invalid fields",
        parameter => [@invalidFields],
    ) if @invalidFields;

    # Delete unchanged fields
    my $patron = Koha::Patrons->find({
        borrowernumber => $changes->{borrowernumber}
    });
    return $self unless $patron;
    my $current_data = $patron->unblessed;
    foreach my $key ( keys %{$changes} ) {
        if ( defined $current_data->{$key} &&
             $current_data->{$key} eq $changes->{$key} ||
             !defined $current_data->{$key} && $changes->{$key} eq '' )
        {
            unless ($key eq 'borrowernumber') {
                $self->set({ $key => undef });
            }
            delete $changes->{$key};
        }
    }

    my $extended_attributes = try { from_json( $self->extended_attributes ) };
    if (!keys %{$changes} && $extended_attributes) {
        my %codes = map { $_->{code} => $_->{value} } @{$extended_attributes};
        foreach my $code (keys %codes) {
            delete $codes{$code} if Koha::Patron::Attributes->search({
                    borrowernumber => $patron->borrowernumber,
                    code           => $code,
                    attribute      => $codes{$code}
                })->count > 0;
        }
        delete $changes->{extended_attributes} unless keys %codes;
    }
    Koha::Exceptions::NoChanges->throw(
        error => "No changes have been made",
    ) unless keys %{$changes};

    $self->set($changes);
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
