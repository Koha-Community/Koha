package Koha::Policy::Patrons::Cardnumber;

# Copyright 2023 Koha Development team
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

use Koha::Patrons;
use Koha::Result::Boolean;

=head1 NAME

Koha::Policy::Patrons::Cardnumber - module to deal with cardnumbers policy

=head1 API

=head2 Class Methods

=head3 new

=cut

sub new {
    return bless {}, shift;
}

=head3 is_valid

    my $is_valid = Koha::Policy::Patrons::Cardnumber->is_valid( $cardnumber, [$patron] );

Returns whether a cardnumber is valid of not for a given I<Koha::Patron> object.

=cut

sub is_valid {
    my ( $class, $cardnumber, $patron ) = @_;

    return Koha::Result::Boolean->new(0)->add_message( { message => "is_empty" } )
        unless defined $cardnumber;

    return Koha::Result::Boolean->new(0)->add_message( { message => "already_exists" } )
        if Koha::Patrons->search(
        {
            cardnumber => $cardnumber,
            ( $patron ? ( borrowernumber => { '!=' => $patron->borrowernumber } ) : () )
        }
    )->count;

    my ( $min_length, $max_length ) = $class->get_valid_length();
    return Koha::Result::Boolean->new(0)->add_message( { message => "invalid_length" } )
        if length $cardnumber > $max_length
        or length $cardnumber < $min_length;

    return Koha::Result::Boolean->new(1);
}

=head2 get_valid_length

    my ($min, $max) = Koha::Policy::Patrons::Cardnumber::get_valid_length();

Returns the minimum and maximum length for patron cardnumbers as
determined by the CardnumberLength system preference, the
BorrowerMandatoryField system preference, and the width of the
database column.

=cut

sub get_valid_length {
    my ($class)    = @_;
    my $borrower   = Koha::Database->new->schema->resultset('Borrower');
    my $field_size = $borrower->result_source->column_info('cardnumber')->{size};
    my ( $min, $max ) = ( 0, $field_size );    # borrowers.cardnumber is a nullable varchar(20)
    $min = 1 if C4::Context->preference('BorrowerMandatoryField') =~ /cardnumber/;
    if ( my $cardnumber_length = C4::Context->preference('CardnumberLength') ) {

        # Is integer and length match
        if ( $cardnumber_length =~ m|^\d+$| ) {
            $min = $max = $cardnumber_length
                if $cardnumber_length >= $min
                and $cardnumber_length <= $max;
        }

        # Else assuming it is a range
        elsif ( $cardnumber_length =~ m|(\d*),(\d*)| ) {
            $min = $1 if $1 and $min < $1;
            $max = $2 if $2 and $max > $2;
        }

    }
    $min = $max if $min > $max;
    return ( $min, $max );
}

1;
