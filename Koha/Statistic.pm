package Koha::Statistic;

# Copyright 2019, 2023 Koha development team
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Items;
use Koha::BackgroundJob::PseudonymizeStatistic;

use base qw(Koha::Object);

our @allowed_accounts_types     = qw( writeoff payment );
our @allowed_circulation_types  = qw( renew issue localuse return onsite_checkout recall item_found item_lost );
our @mandatory_accounts_keys    = qw( type branch borrowernumber value );    # note that amount is mapped to value
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
    amount             : transaction amount (legacy parameter name)
    value              : transaction amount
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

    Koha::Exceptions::BadParameter->throw( parameter => $params ) if !$params || ref($params) ne 'HASH';
    Koha::Exceptions::WrongParameter->throw( name => 'type', value => $params->{type} ) if !$params->{type};

    if ( exists $params->{amount} ) {    # legacy amount parameter still supported
        $params->{value} //= delete $params->{amount};
    }

    my $category;
    if ( grep { $_ eq $params->{type} } @allowed_circulation_types ) {
        $category = 'circulation';
    } elsif ( grep { $_ eq $params->{type} } @allowed_accounts_types ) {
        $category = 'accounts';
    } else {
        Koha::Exceptions::WrongParameter->throw( name => 'type', value => $params->{type} );
    }

    my @mandatory_keys = $category eq 'circulation' ? @mandatory_circulation_keys : @mandatory_accounts_keys;
    my @missing        = map { exists $params->{$_} ? () : $_ } @mandatory_keys;
    Koha::Exceptions::MissingParameter->throw( parameter => join( ',', @missing ) ) if @missing;

    my $datetime = $params->{datetime} ? $params->{datetime} : dt_from_string();
    return $class->SUPER::new(
        {
            borrowernumber => $params->{borrowernumber},    # no longer sending empty string (changed 2023)
            branch         => $params->{branch},
            categorycode   => $params->{categorycode},
            ccode          => exists $params->{ccode} ? $params->{ccode} : q{},
            datetime       => $datetime,
            interface      => $params->{interface} // C4::Context->interface,
            itemnumber     => $params->{itemnumber},
            itemtype       => exists $params->{itemtype} ? $params->{itemtype} : q{},
            location       => $params->{location},
            other          => exists $params->{other} ? $params->{other} : q{},
            type           => $params->{type},
            value          => exists $params->{value} ? $params->{value} : 0,

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
    $self->pseudonymize() if C4::Context->preference('Pseudonymization');
    return $self;
}

=head3 item

    my $item = $statistic->item;

    Return the item associated to this statistic.

=cut

sub item {
    my ( $self ) = @_;
    return Koha::Items->find( $self->itemnumber );
}

=head3 pseudonymize

my $pseudonymized_stat = $statistic->pseudonymize;

Generate a pesudonymized version of the statistic.

=cut

sub pseudonymize {
    my ($self) = @_;

    return unless ( $self->borrowernumber && grep { $_ eq $self->type } qw(renew issue return onsite_checkout) );

    # FIXME When getting the object from svc/renewal we get a DateTime object
    # normally we just fetch from DB to clear this, but statistics has no primary key
    # so we just force it to string context
    my $unblessed = $self->unblessed;
    $unblessed->{datetime} = $unblessed->{datetime} . "";

    Koha::BackgroundJob::PseudonymizeStatistic->new->enqueue( { statistic => $unblessed } );

}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Statistic';
}

1;
