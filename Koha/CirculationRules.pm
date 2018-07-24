package Koha::CirculationRules;

# Copyright Vaara-kirjastot 2015
# Copyright Koha Development Team 2016
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

use Carp qw(croak);

use Koha::CirculationRule;

use base qw(Koha::Objects);

=head1 NAME

Koha::IssuingRules - Koha IssuingRule Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_effective_rule

=cut

sub get_effective_rule {
    my ( $self, $params ) = @_;

    my $rule_name    = $params->{rule_name};
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $branchcode   = $params->{branchcode};

    croak q{No rule name passed in!} unless $rule_name;

    my $search_params;
    $search_params->{rule_name} = $rule_name;

    $search_params->{categorycode} = defined $categorycode ? [ $categorycode, undef ] : undef;
    $search_params->{itemtype}     = defined $itemtype     ? [ $itemtype, undef ] : undef;
    $search_params->{branchcode}   = defined $branchcode   ? [ $branchcode,   undef ] : undef;

    my $rule = $self->search(
        $search_params,
        {
            order_by => {
                -desc => [ 'branchcode', 'categorycode', 'itemtype' ]
            },
            rows => 1,
        }
    )->single;

    return $rule;
}

=head3 set_rule

=cut

sub set_rule {
    my ( $self, $params ) = @_;

    croak q{set_rule requires the parameter 'branchcode'!}
      unless exists $params->{branchcode};
    croak q{set_rule requires the parameter 'categorycode'!}
      unless exists $params->{categorycode};
    croak q{set_rule requires the parameter 'itemtype'!}
      unless exists $params->{itemtype};
    croak q{set_rule requires the parameter 'rule_name'!}
      unless exists $params->{rule_name};
    croak q{set_rule requires the parameter 'rule_value'!}
      unless exists $params->{rule_value};

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

    foreach my $rule (@$rules) {
        Koha::CirculationRules->set_rule(
            {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype,
                rule_name    => $rule->{rule_name},
                rule_value   => $rule->{rule_value},
            }
        );
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
