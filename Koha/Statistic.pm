package Koha::Statistic;

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

use C4::Context;
use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Items;
use Koha::PseudonymizedTransaction;

use base qw(Koha::Object);

our @allowed_accounts_types     = qw( writeoff payment );
our @allowed_circulation_types  = qw( renew issue localuse return onsite_checkout recall item_found item_lost );
our @mandatory_accounts_keys    = qw( type branch borrowernumber amount );
our @mandatory_circulation_keys = qw( type branch borrowernumber itemnumber ccode itemtype );

=head1 NAME

Koha::Statistic - Koha Statistic Object class

=head1 API

=head2 Class methods

=head3 new

    my $record = Koha::Statistic->new( $params );

    C<$params> is an hashref whose expected keys are:
    branch             : transaction branch
    type               : transaction type
    itemnumber         : itemnumber
    borrowernumber     : borrowernumber
    categorycode       : patron category
    amount             : transaction amount
    other              : sipmode
    itemtype           : itemtype
    ccode              : collection code
    interface          : the context this action was taken in

    The type key is mandatory, see @Koha::Statistic::allowed_account_types or
    @Koha::Statistic::allowed_circulation_types.
    Some keys are mandatory, depending on type. See @mandatory_accounts_keys
    or @mandatory_circulation_keys.

    The method throws an exception when given bad data, otherwise returns a
    Koha::Statistic object, which is not yet stored.

=cut

sub new {
    my ( $class, $params ) = @_;

    # make some controls
    return () if !defined $params;

    # change these arrays if new types of transaction or new parameters are allowed
    my @allowed_keys =
        qw (type branch amount other itemnumber itemtype borrowernumber ccode location categorycode interface);

    my @mandatory_keys = ();
    if ( !exists $params->{type} or !defined $params->{type} ) {
        croak("UpdateStats did not received type param");
    }
    if ( grep ( $_ eq $params->{type}, @allowed_circulation_types ) ) {
        @mandatory_keys = @mandatory_circulation_keys;
    } elsif ( grep ( $_ eq $params->{type}, @allowed_accounts_types ) ) {
        @mandatory_keys = @mandatory_accounts_keys;
    } else {
        croak( "UpdateStats received forbidden type param: " . $params->{type} );
    }
    my @missing_params = ();
    for my $mykey (@mandatory_keys) {
        push @missing_params, $mykey if !grep ( /^$mykey/, keys %$params );
    }
    if ( scalar @missing_params > 0 ) {
        croak( "UpdateStats did not received mandatory param(s): " . join( ", ", @missing_params ) );
    }
    my @invalid_params = ();
    for my $myparam ( keys %$params ) {
        push @invalid_params, $myparam unless grep { $_ eq $myparam } @allowed_keys;
    }
    if ( scalar @invalid_params > 0 ) {
        croak( "UpdateStats received invalid param(s): " . join( ", ", @invalid_params ) );
    }

    # get the parameters
    my $branch         = $params->{branch};
    my $type           = $params->{type};
    my $borrowernumber = exists $params->{borrowernumber} ? $params->{borrowernumber} : '';
    my $itemnumber     = exists $params->{itemnumber}     ? $params->{itemnumber}     : undef;
    my $amount         = exists $params->{amount}         ? $params->{amount}         : 0;
    my $other          = exists $params->{other}          ? $params->{other}          : '';
    my $itemtype       = exists $params->{itemtype}       ? $params->{itemtype}       : '';
    my $location       = exists $params->{location}       ? $params->{location}       : undef;
    my $ccode          = exists $params->{ccode}          ? $params->{ccode}          : '';
    my $categorycode   = exists $params->{categorycode}   ? $params->{categorycode}   : undef;
    my $interface      = exists $params->{interface}      ? $params->{interface}      : undef;

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $class->SUPER::new(
        {
            datetime       => $dtf->format_datetime( dt_from_string() ),
            branch         => $branch,
            type           => $type,
            value          => $amount,
            other          => $other,
            itemnumber     => $itemnumber,
            itemtype       => $itemtype,
            location       => $location,
            borrowernumber => $borrowernumber,
            categorycode   => $categorycode,
            ccode          => $ccode,
            interface      => $interface,
        }
    );
}

=head3 store

    $statistic->store;

    This call includes pseudonymization if enabled.

=cut

sub store {
    my ($self) = @_;
    $self->SUPER::store;
    Koha::PseudonymizedTransaction->new_from_statistic($self)->store
        if C4::Context->preference('Pseudonymization')
        && $self->borrowernumber    # Not a real transaction if the patron does not exist
                                    # For instance can be a transfer, or hold trigger
        && grep { $_ eq $self->type } qw(renew issue return onsite_checkout);
    return $self;
}

=head3 insert

    Koha::Statistic->insert( $params );

    This is a shorthand for ->new($params)->store.
    It is the new equivalent for the legacy C4::Stats::UpdateStats call.

=cut

sub insert {
    my ( $class, $params ) = @_;
    my $statistic = $class->new($params) or return;
    $statistic->store;
    return $statistic;
}

=head3 item

    my $item = $statistic->item;

    Return the item associated to this statistic.

=cut

sub item {
    my ( $self ) = @_;
    return Koha::Items->find( $self->itemnumber );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Statistic';
}

1;
