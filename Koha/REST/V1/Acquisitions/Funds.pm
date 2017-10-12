package Koha::REST::V1::Acquisitions::Funds;

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

use C4::Budgets;
use JSON qw(to_json);

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Acquisitions::Funds

=head1 API

=head2 Methods

=head3 list_funds

Controller function that handles listing Funds

=cut

sub list_funds {
    my $c = shift->openapi->valid_input or return;

    my $args = _to_model($c->req->params->to_hash);
    my $filter;

    for my $filter_param ( keys %$args ) {
        $filter->{$filter_param} = { LIKE => $args->{$filter_param} . "%" }
            if $args->{$filter_param};
    }

    return try {
        my $funds = GetBudgets($filter);
        my @fundsArray = map { _to_api($_) } @$funds;
        return $c->render( status  => 200,
                           openapi =>  \@fundsArray);
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs. $_ $filter" } );
        }
    };
}

=head3 _to_api

Helper function that maps a Fund  into
the attribute names the exposed REST api spec.

=cut

sub _to_api {
    my $fund = shift;
    my $returnfund;
    $returnfund->{id} = delete $fund->{budget_id};
    $returnfund->{code} = delete $fund->{budget_code};
    $returnfund->{name} = delete $fund->{budget_name};

    return $returnfund;
}

=head3 _to_model

Helper function that maps REST api objects into Fund
attribute names.

=cut

sub _to_model {
    my $fund = shift;

    # Rename back
    $fund->{budget_id}     = delete $fund->{id};
    $fund->{budget_code}   = delete $fund->{code};
    $fund->{budget_name}   = delete $fund->{name};

    return $fund;
}

1;
