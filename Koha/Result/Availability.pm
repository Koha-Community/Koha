package Koha::Result::Availability;

# Copyright 2026 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Exceptions;
use Koha::Token;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::Result::Availability - Base class for availability check results

=head1 SYNOPSIS

    my $result = Koha::Result::Availability->new();

    $result->add_blocker( BadBarcode => $barcode );
    $result->add_confirmation( NotIssued => $barcode );
    $result->add_warning( withdrawn => 1 );

    if ( $result->available ) {
        # Proceed with action
    }

=head1 DESCRIPTION

This class provides a standardized structure for availability check results
across different operations (check-in, checkout, hold, renewal, etc.).

Results are categorized into:
- blockers: Conditions that prevent the action
- confirmations: Conditions requiring user confirmation
- warnings: Informational messages that don't prevent the action

=head1 API

=head2 Class methods

=head3 new

    my $result = Koha::Result::Availability->new();

Constructor. Creates a new result object with empty blockers, confirmations,
and warnings.

=cut

sub new {
    my ($class) = @_;

    my $self = {
        blockers      => {},
        confirmations => {},
        warnings      => {},
        context       => {},
    };

    return bless $self, $class;
}

=head2 Instance methods

=head3 add_blocker

    $result->add_blocker( $key => $value );

Adds a blocker. Blockers prevent the action from proceeding.

=cut

sub add_blocker {
    my ( $self, $key, $value ) = @_;
    $self->{blockers}->{$key} = $value;
    return $self;
}

=head3 add_confirmation

    $result->add_confirmation( $key => $value );

Adds a confirmation requirement. Confirmations require user acknowledgment
before proceeding.

=cut

sub add_confirmation {
    my ( $self, $key, $value ) = @_;
    $self->{confirmations}->{$key} = $value;
    return $self;
}

=head3 add_warning

    $result->add_warning( $key => $value );

Adds a warning. Warnings are informational and don't prevent the action.

=cut

sub add_warning {
    my ( $self, $key, $value ) = @_;
    $self->{warnings}->{$key} = $value;
    return $self;
}

=head3 set_context

    $result->set_context( $key => $value );

Sets a context value. Context provides additional information about the
availability check (e.g., related objects like item, checkout, patron).

=cut

sub set_context {
    my ( $self, $key, $value ) = @_;
    $self->{context}->{$key} = $value;
    return $self;
}

=head3 available

    if ( $result->available ) { ... }

Returns true if there are no blockers, false otherwise.

=cut

sub available {
    my ($self) = @_;
    return keys %{ $self->{blockers} } == 0;
}

=head3 needs_confirmation

    if ( $result->needs_confirmation ) { ... }

Returns true if there are confirmations required, false otherwise.

=cut

sub needs_confirmation {
    my ($self) = @_;
    return keys %{ $self->{confirmations} } > 0;
}

=head3 blockers

    my $blockers = $result->blockers;

Returns the blockers hashref.

=cut

sub blockers {
    my ($self) = @_;
    return $self->{blockers};
}

=head3 confirmations

    my $confirmations = $result->confirmations;

Returns the confirmations hashref.

=cut

sub confirmations {
    my ($self) = @_;
    return $self->{confirmations};
}

=head3 warnings

    my $warnings = $result->warnings;

Returns the warnings hashref.

=cut

sub warnings {
    my ($self) = @_;
    return $self->{warnings};
}

=head3 context

    my $context = $result->context;
    my $item = $result->context->{item};

Returns the context hashref.

=cut

sub context {
    my ($self) = @_;
    return $self->{context};
}

=head3 token_params

Abstract method. Subclasses override to return an arrayref of context
keys used for token generation.

=cut

sub token_params {
    Koha::Exception->throw("Subclass must implement token_params");
}

=head3 as_token

Generates a JWT confirmation token.

=cut

sub as_token {
    my ($self) = @_;
    return Koha::Token->new->generate_jwt( { id => $self->_token_id } );
}

=head3 check_token

Validates a JWT confirmation token.

=cut

sub check_token {
    my ( $self, $token ) = @_;
    return try {
        Koha::Token->new->check_jwt( { id => $self->_token_id, token => $token } );
    } catch {
        return 0;
    };
}

=head3 _token_id

=cut

sub _token_id {
    my ($self) = @_;
    my @parts;
    for my $key ( sort @{ $self->token_params } ) {
        my $obj = $self->{context}->{$key} // Koha::Exception->throw("Missing context for token: $key");
        push @parts, $obj->id;
    }
    push @parts, sort keys %{ $self->{confirmations} };
    return join( ':', @parts );
}

=head3 to_api

    my $hashref = $result->to_api;

Returns a hashref suitable for API responses. Includes a
C<confirmation_token> when confirmations exist.

=cut

sub to_api {
    my ($self) = @_;

    return {
        blockers           => $self->{blockers},
        confirms           => $self->{confirmations},
        warnings           => $self->{warnings},
        confirmation_token => $self->needs_confirmation ? $self->as_token : undef,
    };
}

=head3 to_hashref

    my $hashref = $result->to_hashref;

Returns a plain hashref representation of the result, suitable for
backward compatibility or serialization.

=cut

sub to_hashref {
    my ($self) = @_;

    return {
        blockers => $self->{blockers},
        confirms => $self->{confirmations},
        warnings => $self->{warnings},
        %{ $self->{context} },
    };
}

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut

1;
