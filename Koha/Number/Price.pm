package Koha::Number::Price;

# This file is part of Koha.
#
# Copyright 2014 BibLibre
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

use Number::Format qw( format_price );
use C4::Context;
use Koha::Acquisition::Currencies;

use base qw( Class::Accessor );
__PACKAGE__->mk_accessors(qw( value ));

sub new {
    my ( $class, $value ) = @_;

    my $self->{value} = $value || 0;

    bless $self, $class;
    return $self;
}

sub format {
    my ( $self, $params ) = @_;
    return unless defined $self->value;

    my $format_params = $self->_format_params( $params );

    # To avoid the system to crash, we will not format big number
    # We divide per 100 because we want to keep the default DECIMAL_DIGITS (2)
    # error - round() overflow. Try smaller precision or use Math::BigFloat
    return $self->value if $self->value > Number::Format::MAX_INT/100;

    return Number::Format->new(%$format_params)->format_price($self->value);
}

sub format_for_editing {
    my ( $self, $params ) = @_;
    return unless defined $self->value;

    my $format_params = $self->_format_params( $params );
    $format_params = {
        %$format_params,
        int_curr_symbol   => '',
        mon_thousands_sep => '',
        mon_decimal_point => '.',
    };

    return Number::Format->new(%$format_params)->format_price($self->value);
}

sub unformat {
    my ( $self, $params ) = @_;
    return unless defined $self->value;

    my $format_params = $self->_format_params( $params );

    return Number::Format->new(%$format_params)->unformat_number($self->value);
}

sub round {
    my ( $self ) = @_;
    return unless defined $self->value;

    my $format_params = $self->_format_params;

    return Number::Format->new(%$format_params)->round($self->value);
}

sub _format_params {
    my ( $self, $params ) = @_;
    my $with_symbol = $params->{with_symbol} || 0;
    my $p_cs_precedes = $params->{p_cs_precedes};
    my $p_sep_by_space = $params->{p_sep_by_space};
    my $currency        = Koha::Acquisition::Currencies->get_active;
    my $currency_format = C4::Context->preference("CurrencyFormat");

    my $int_curr_symbol = q||;
    my %format_params = (
        decimal_fill      => '2',
        decimal_point     => '.',
        int_curr_symbol   => $int_curr_symbol,
        mon_thousands_sep => ',',
        thousands_sep     => ',',
        mon_decimal_point => '.'
    );

    if ( $currency_format eq 'FR' ) {
        # FIXME This test should be done for all currencies
        $int_curr_symbol = $currency->symbol if $with_symbol;
        %format_params = (
            decimal_fill      => '2',
            decimal_point     => ',',
            int_curr_symbol   => $int_curr_symbol,
            mon_thousands_sep => ' ',
            thousands_sep     => ' ',
            mon_decimal_point => ','
        );
    }

    if ( $currency_format eq 'CH' ) {
        $int_curr_symbol = $currency->symbol if $with_symbol;
        %format_params = (
            decimal_fill      => '2',
            decimal_point     => '.',
            int_curr_symbol   => $int_curr_symbol,
            mon_thousands_sep => '\'',
            thousands_sep     => '\'',
            mon_decimal_point => '.'
        );
    }


    $format_params{p_cs_precedes}  = $p_cs_precedes  if defined $p_cs_precedes;
    $format_params{p_sep_by_space} = ( $int_curr_symbol and defined $p_sep_by_space ) ? $p_sep_by_space : 0;

    return \%format_params;
}

1;
