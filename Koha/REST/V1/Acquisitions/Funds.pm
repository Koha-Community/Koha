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

use Koha::Acquisition::Funds;

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
        if ($args->{$filter_param}) {
            if ($filter_param eq "budget_owner_id") {
                # Perform an exact search on the borrowernumber
                $filter->{$filter_param} = { "=" => $args->{$filter_param} }
            } else {
                # And a "start with" search on the budget name
                $filter->{$filter_param} = { LIKE => $args->{$filter_param} . "%" }
            }
        }
    }

    return try {
        my @funds = Koha::Acquisition::Funds->search($filter);
        @funds = map { _to_api($_->TO_JSON) } @funds;
        return $c->render( status  => 200,
                           openapi =>  \@funds);
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
    $returnfund->{fund_id} = delete $fund->{budget_id};
    $returnfund->{code} = delete $fund->{budget_code};
    $returnfund->{name} = delete $fund->{budget_name};
    $returnfund->{library_id} = delete $fund->{budget_branchcode};
    $returnfund->{total_amount} = delete $fund->{budget_amount};
    $returnfund->{warn_at_percentage} = delete $fund->{budget_encumb};
    $returnfund->{warn_at_amount} = delete $fund->{budget_expend};
    $returnfund->{notes} = delete $fund->{budget_notes};
    $returnfund->{budget_id} = delete $fund->{budget_period_id};
    $returnfund->{timestamp} = delete $fund->{timestamp};
    $returnfund->{fund_owner_id} = delete $fund->{budget_owner_id};
    $returnfund->{fund_access} = delete $fund->{budget_permission};
    $returnfund->{statistic1_auth_value_category} = delete $fund->{sort1_authcat};
    $returnfund->{statistic2_auth_value_category} = delete $fund->{sort2_authcat};

    return $returnfund;
}

=head3 _to_model

Helper function that maps REST api objects into Fund
attribute names.

=cut

sub _to_model {
    my $fund = shift;
    my $returnfund;

    # Rename back
    $returnfund->{budget_id} = delete $fund->{fund_id};
    $returnfund->{budget_code} = delete $fund->{code};
    $returnfund->{budget_name} = delete $fund->{name};
    $returnfund->{budget_branchcode} = delete $fund->{library_id};
    $returnfund->{budget_amount} = delete $fund->{total_amount};
    $returnfund->{budget_encumb} = delete $fund->{warn_at_percentage};
    $returnfund->{budget_expend} = delete $fund->{warn_at_amount};
    $returnfund->{budget_notes} = delete $fund->{notes};
    $returnfund->{budget_period_id} = delete $fund->{budget_id};
    $returnfund->{budget_owner_id} = delete $fund->{fund_owner_id};
    $returnfund->{timestamp} = delete $fund->{timestamp};
    $returnfund->{budget_permission} = delete $fund->{fund_access};
    $returnfund->{sort1_authcat} = delete $fund->{statistic1_auth_value_category};
    $returnfund->{sort2_authcat} = delete $fund->{statistic2_auth_value_category};

    return $returnfund;
}

1;
