package Koha::PseudonymizedTransaction;

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
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Crypt::Eksblowfish::Bcrypt qw( bcrypt );
use List::MoreUtils            qw(any);

use Koha::Database;
use Koha::Exceptions::Config;
use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::PseudonymizedTransaction - Koha Koha::PseudonymizedTransaction Object class

=head1 API

=head2 Class methods

=head3 create_from_statistic

    Creates a new object from a passed Koha::Statistic object and stores it in the database

=cut

sub create_from_statistic {
    my ( $class, $statistic ) = @_;

    my $values = {
        hashed_borrowernumber => $class->get_hash( $statistic->borrowernumber ),
    };

    my @t_fields_to_copy = split ',', C4::Context->preference('PseudonymizationTransactionFields') || '';

    my $statistic_item = $statistic->item;

    # These fields are treated separately as the column names do not match
    if ( any { $_ eq 'transaction_branchcode' } @t_fields_to_copy ) {
        $values->{transaction_branchcode} = $statistic->branch;
    }
    if ( any { $_ eq 'transaction_type' } @t_fields_to_copy ) {
        $values->{transaction_type} = $statistic->type;
    }

    # These fields are not captured in the statistic so must be pulled from the item
    if ($statistic_item) {
        if ( any { $_ eq 'homebranch' } @t_fields_to_copy ) {
            $values->{homebranch} = $statistic_item->homebranch;
        }
        if ( any { $_ eq 'holdingbranch' } @t_fields_to_copy ) {
            $values->{holdingbranch} = $statistic_item->holdingbranch;
        }
        if ( any { $_ eq 'itemcallnumber' } @t_fields_to_copy ) {
            $values->{itemcallnumber} = $statistic_item->itemcallnumber;
        }
    }

    # Remove fields we have already handled from the list
    @t_fields_to_copy = grep {
               $_ ne 'transaction_branchcode'
            && $_ ne 'holdingbranch'
            && $_ ne 'homebranch'
            && $_ ne 'transaction_type'
            && $_ ne 'itemcallnumber'
    } @t_fields_to_copy;

    # Populate the remaining columns
    $values = { %$values, map { $_ => $statistic->$_ } @t_fields_to_copy };

    my $patron = Koha::Patrons->find( $statistic->borrowernumber );
    if ($patron) {
        my @p_fields_to_copy = split ',', C4::Context->preference('PseudonymizationPatronFields') || '';
        $values = { %$values, map { $_ => $patron->$_ } @p_fields_to_copy };

        $values->{branchcode}   = $patron->branchcode;  # FIXME Must be removed from the pref options, or FK removed (?)
        $values->{categorycode} = $patron->categorycode;

        $values->{has_cardnumber} = $patron->cardnumber ? 1 : 0;
    }

    my $self = $class->SUPER::new($values);

    $self->store();

    if ($patron) {
        my @kept_types = Koha::Patron::Attribute::Types->search(
            { keep_for_pseudonymization => 1 },
            { columns                   => ['code'] }
        )->get_column('code');

        if (@kept_types) {
            my $extended_attributes =
                $patron->extended_attributes->search( { code => { -in => \@kept_types } } )->unblessed;

            for my $attribute (@$extended_attributes) {
                delete $attribute->{id};
                delete $attribute->{borrowernumber};

                $self->_result->create_related( 'pseudonymized_borrower_attributes', $attribute );
            }
        }
    }

    return $self;
}

=head3 get_hash

    Generates a hashed value for $s (e.g. borrowernumber) with Bcrypt.
    Needs config entry 'bcrypt_settings' in koha-conf.

=cut

sub get_hash {
    my ( $class, $s ) = @_;
    my $bcrypt_settings = C4::Context->config('bcrypt_settings');

    Koha::Exceptions::Config::MissingEntry->throw("Missing 'bcrypt_settings' entry in config file")
        unless $bcrypt_settings;

    return bcrypt( $s, $bcrypt_settings );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'PseudonymizedTransaction';
}

1;
