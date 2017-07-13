package Koha::CirculationRules;

# Copyright ByWater Solutions 2017
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

use Koha::Exceptions;
use Koha::CirculationRule;

use base qw(Koha::Objects);

=head1 NAME

Koha::CirculationRules - Koha CirculationRule Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_effective_rule

=cut

sub get_effective_rule {
    my ( $self, $params ) = @_;

    $params->{categorycode} = '*' if exists($params->{categorycode}) && !defined($params->{categorycode});
    $params->{branchcode}   = '*' if exists($params->{branchcode})   && !defined($params->{branchcode});
    $params->{itemtype}     = '*' if exists($params->{itemtype})     && !defined($params->{itemtype});

    my $rule_name    = $params->{rule_name};
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $branchcode   = $params->{branchcode};

    Koha::Exceptions::MissingParameter->throw(
        "Required parameter 'rule_name' missing")
      unless $rule_name;

    for my $v ( $branchcode, $categorycode, $itemtype ) {
        $v = undef if $v and $v eq '*';
    }

    my $order_by = $params->{order_by}
      // { -desc => [ 'branchcode', 'categorycode', 'itemtype' ] };

    my $search_params;
    $search_params->{rule_name} = $rule_name;

    $search_params->{categorycode} = defined $categorycode ? [ $categorycode, undef ] : undef;
    $search_params->{itemtype}     = defined $itemtype     ? [ $itemtype, undef ] : undef;
    $search_params->{branchcode}   = defined $branchcode   ? [ $branchcode,   undef ] : undef;

    my $rule = $self->search(
        $search_params,
        {
            order_by => $order_by,
            rows => 1,
        }
    )->single;

    return $rule;
}

=head3 get_effective_rule

=cut

sub get_effective_rules {
    my ( $self, $params ) = @_;

    my $rules        = $params->{rules};
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $branchcode   = $params->{branchcode};

    my $r;
    foreach my $rule (@$rules) {
        my $effective_rule = $self->get_effective_rule(
            {
                rule_name    => $rule,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                branchcode   => $branchcode,
            }
        );

        $r->{$rule} = $effective_rule->rule_value if $effective_rule;
    }

    return $r;
}

=head3 set_rule

=cut

sub set_rule {
    my ( $self, $params ) = @_;

    for my $mandatory_parameter (qw( branchcode categorycode itemtype rule_name rule_value ) ){
        Koha::Exceptions::MissingParameter->throw(
            "Required parameter 'branchcode' missing")
          unless exists $params->{$mandatory_parameter};
    }

    my $branchcode   = $params->{branchcode};
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $rule_name    = $params->{rule_name};
    my $rule_value   = $params->{rule_value};

    for my $v ( $branchcode, $categorycode, $itemtype ) {
        $v = undef if $v and $v eq '*';
    }
    my $rule = $self->search(
        {
            rule_name    => $rule_name,
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
        }
    )->next();

    if ($rule) {
        if ( defined $rule_value ) {
            $rule->rule_value($rule_value);
            $rule->update();
        }
        else {
            $rule->delete();
        }
    }
    else {
        if ( defined $rule_value ) {
            $rule = Koha::CirculationRule->new(
                {
                    branchcode   => $branchcode,
                    categorycode => $categorycode,
                    itemtype     => $itemtype,
                    rule_name    => $rule_name,
                    rule_value   => $rule_value,
                }
            );
            $rule->store();
        }
    }

    return $rule;
}

=head3 set_rules

=cut

sub set_rules {
    my ( $self, $params ) = @_;

    my $branchcode   = $params->{branchcode};
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $rules        = $params->{rules};

    my $rule_objects = [];
    while ( my ( $rule_name, $rule_value ) = each %$rules ) {
        my $rule_object = Koha::CirculationRules->set_rule(
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => $rule_name,
                rule_value   => $rule_value,
            }
        );
        push( @$rule_objects, $rule_object );
    }

    return $rule_objects;
}

=head3 delete

Delete a set of circulation rules, needed for cleaning up when deleting issuingrules

=cut

sub delete {
    my ( $self ) = @_;

    while ( my $rule = $self->next ){
        $rule->delete;
    }

}

=head3 type

=cut

sub _type {
    return 'CirculationRule';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::CirculationRule';
}

1;
